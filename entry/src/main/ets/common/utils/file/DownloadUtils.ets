import { DownloadItem } from "../../model/Download"
import { getContext_ } from "../system/AppUtils"
import { DownloadConfig, DownloadListener, DownloadManager, DownloadTask } from "@hadss/super_fast_file_trans"
import { StorageConstants } from "../../constants/StorageConstants"
import { Song, SongDownloadItem } from "../../entities/Song"
import { getDownloadInfo } from "../../../api/getDownloadInfo"
import { getArtists, sanitizeFileName } from "../../functions/common/convert"
import FileUtils from "./FileUtils"
import { FileUtil, LogUtil, ToastUtil } from "@pura/harmony-utils"
import RelationalStoreUtils from "../data/RelationalStoreUtils"
import PreferencesUtils from "../data/PreferencesUtils"
import { PlayConstants } from "../../constants/PlayConstants"
import FileDownloadUtils from "./FileDownloadUtils"
import { getLyricString } from "../../../api/LyricApi"
import LyricUtils from "../play/LyricUtils"
import { getSongPicUrl } from "../../../api/songApi"
import BackgroundTaskUtils from "../play/BackgroundTaskUtils"

const TAG = '[DownloadUtils] '

class DownloadUtils {
  private list: DownloadItem[] = []
  private downloadManager: DownloadManager | null = null
  private downloadTask: DownloadTask | undefined = undefined
  private currentIndex: number = 0

  async init() {
    this.list = await PreferencesUtils.getPreferenceValue<DownloadItem[]>(StorageConstants.QUEUE_PREF, StorageConstants.DOWNLOAD_QUEUE, [])
    AppStorage.setOrCreate(StorageConstants.DOWNLOAD_QUEUE, this.list)
    const context = getContext_()
    this.getManager().init(context)
    LogUtil.info(TAG, `DownloadUtils inited.`)
  }

  private getDownloadListener(song: Song, fileName: string): DownloadListener {
    return {
      onStart: () => {
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOADING, true)
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, false)
      },
      onPause: () => {
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, true)
      },
      onResume: () => {
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, false)
      },
      onCancel: () => {
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOADING, false)
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, false)
      },
      onProgressUpdate: (info) => {
        let progress = ((info.transferredSize / info.totalSize) * 100).toFixed(1)
        AppStorage.setOrCreate(StorageConstants.DOWNLOADING_PROGRESS, progress)
      },
      onSuccess: () => {
        let cachePath = FileUtils.getCacheDir() + `/${fileName}`
        let descPath = FileUtils.getFilesDir() + `/${fileName}`

        FileUtils.moveFile(cachePath, descPath).then(() => {
          RelationalStoreUtils.addSong({
            id: 0,
            songId: song.id,
            name: song.name,
            artists: JSON.stringify(song.artists),
            picFile: "",
            songFile: fileName,
            lyricFile: ""
          })
        })
        this.deleteByIndex(0)
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, false)
        AppStorage.setOrCreate(StorageConstants.DOWNLOADING_PROGRESS, '0')
        setTimeout(() => {
          this.startTask(0)
        }, 1000)
      },
      onFail: (err) => {
        LogUtil.error(TAG, `err: ${err.code} - ${err.message}`)
        this.deleteByIndex(0)
        AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, false)
        AppStorage.setOrCreate(StorageConstants.DOWNLOADING_PROGRESS, '0')
        setTimeout(() => {
          this.startTask(0)
        }, 1000)
      }
    }
  }

  getManager(): DownloadManager {
    if(!this.downloadManager) {
      this.downloadManager = DownloadManager.getInstance()
    }
    return this.downloadManager
  }

  getList(): DownloadItem[] {
    return this.list
  }

  getListLength(): number {
    return this.list.length
  }

  getCurrentIndex(): number {
    return this.currentIndex
  }

  async addItem(song: Song[], quality: number) {
    let isLogged = await AppStorage.get(StorageConstants.IS_LOGGED) as boolean
    if(!isLogged) {
      ToastUtil.showToast('请登录后再试')
      return
    }
    const songIds = song.map(item => item.id).join(',')
    let downloadInfo = await getDownloadInfo(songIds, PlayConstants.QUALITY[quality], isLogged)
    const songIdArray = songIds.split(',').map(Number)
    const dataMap = new Map<number, SongDownloadItem>()
    downloadInfo.data.forEach(item => dataMap.set(item.id, item))
    let data = songIdArray.map(id => dataMap.get(id)!).filter(Boolean)
    for(let i = 0; i < song.length; i++) {
      this.list.push({
        song: song[i],
        downloadItem: data[i]
      })
    }
    await this.syncQueue()
    let isDownloading = await AppStorage.get(StorageConstants.IS_DOWNLOADING) as boolean
    if(!isDownloading) {
      this.startTask(0)
    }
  }

  async deleteByIndex(index: number) {
    this.list.splice(index, 1)
    await this.syncQueue()
  }

  async startTask(index: number) {
    AppStorage.setOrCreate(StorageConstants.IS_DOWNLOADING, true)

    let item = this.list[index]

    if (!item) {
      ToastUtil.showToast('已完成所有下载任务')
      AppStorage.setOrCreate(StorageConstants.IS_DOWNLOADING, false)
      AppStorage.setOrCreate(StorageConstants.IS_DOWNLOAD_PAUSED, false)
      await BackgroundTaskUtils.stopBackgroundTask()
      BackgroundTaskUtils.startTask(0)
      return
    }
    let artists = getArtists(item.song.artists)
    if (item.song.name.length + artists.length >= 103) {
      try {
        artists = artists.slice(0, 100 - item.song.name.length)
      } catch (e) {
        artists = 'null'
      }
    }

    let fileName = sanitizeFileName(`${artists} - ${item.song.name}.${item.downloadItem.type}`)
    let descPath = FileUtils.getFilesDir() + `/${fileName}`

    // 文件已存在或歌曲已存在
    if (await FileUtil.access(descPath) || await RelationalStoreUtils.checkSong(item.song.id) === true) {
      this.deleteByIndex(0)
      setTimeout(() => {
        this.startTask(0)
      }, 1000)
      return
    }

    let picUrl = await getSongPicUrl(item.song.id)
    await BackgroundTaskUtils.startTask(1)
    FileDownloadUtils.download(picUrl + '?param=512y512', `${item.song.id}.jpg`, 'pic')
    let lyricString = await getLyricString(item.song.id)
    LyricUtils.saveLyricToFile(lyricString, `${item.song.id}.lrc`)

    let downloadConfig: DownloadConfig = {
      url: item.downloadItem.url,
      fileName: fileName,
      concurrency: 2
    }

    this.downloadTask =
      this.getManager().createDownloadTask(downloadConfig, this.getDownloadListener(item.song, fileName))

    if (this.downloadTask) {
      this.downloadTask.start()
    }
  }

  resumeTask() {
    if(this.downloadTask)
      this.downloadTask.resume()
  }

  pauseTask() {
    if(this.downloadTask)
      this.downloadTask.pause()
  }

  async clearTask() {
    if(this.downloadTask)
      this.downloadTask.cancel()
    this.list = []
    const context = getContext_()
    this.getManager().cleanAll(context)
    await this.syncQueue()
  }

  private async syncQueue() {
    AppStorage.setOrCreate(StorageConstants.DOWNLOAD_QUEUE, this.list)
    await PreferencesUtils.putPreferenceValue(StorageConstants.QUEUE_PREF, StorageConstants.DOWNLOAD_QUEUE, this.list)
  }
}

export default new DownloadUtils()