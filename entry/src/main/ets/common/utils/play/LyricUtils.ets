import { EmitterUtil, LogUtil } from "@pura/harmony-utils"
import { getLyric } from "../../../api/LyricApi"
import { EmitterConstants } from "../../constants/EmitterConstants"
import { StorageConstants } from "../../constants/StorageConstants"
import { Lrc_INITIAL, Lyric, LyricResult, LyricResult_INITIAL } from "../../entities/Lyric"
import { Song } from "../../entities/Song"
import FileUtils from "../file/FileUtils"
import { fileIo, ReadOptions } from "@kit.CoreFileKit"
import { buffer } from "@kit.ArkTS"
import { LyricStyle } from "../../model/Settings"

const TAG = '[LyricUtils] '

class LyricUtils {
  // Lyric Entity
  lyric: LyricResult = LyricResult_INITIAL
  lyricObjects: Array<Lyric> = []
  tLyricObjects: Array<Lyric> = []
  rLyricObjects: Array<Lyric> = []
  currentLyricIndex: number = 0
  updateLyricInterval: number = 0
  isUpdating: boolean = false

  private resetLyric() {
    this.lyric = LyricResult_INITIAL
    this.lyricObjects = []
    this.tLyricObjects = []
    this.rLyricObjects = []
  }

  async setLyric(song: Song) {
    this.resetLyric()
    AppStorage.setOrCreate(StorageConstants.CURRENT_LYRIC, `《${song.name}》`)
    this.currentLyricIndex = 0
    let lyricArr: string[] = []
    try {
      if(song.artists[0].id == 0) {
        this.lyric.lrc.lyric = '[00:00:00] 暂无歌词'
        lyricArr = ['[00:00:00] 暂无歌词']
      } else {
        this.lyric = await getLyric(song.id)
        lyricArr = this.lyric.lrc.lyric.split('\n')
      }
      this.lyricObjects = await this.parseLyricArray(lyricArr)
      if(this.lyric.tlyric.lyric)
        this.tLyricObjects = await this.parseLyricArray(this.lyric.tlyric.lyric.split('\n'))
      if(this.lyric.romalrc.lyric)
        this.rLyricObjects = await this.parseLyricArray(this.lyric.romalrc.lyric.split('\n'))
    } catch (e) {
      LogUtil.error(TAG, 'Set Lyric Error: ' + e.message)
      this.lyric = {
        code: 200, lrc: Lrc_INITIAL, tlyric: Lrc_INITIAL, klyric: Lrc_INITIAL, romalrc: Lrc_INITIAL
      }
      this.lyricObjects = [{ time: 0, content: '暂无歌词' }]
    } finally {
      AppStorage.setOrCreate(StorageConstants.CURRENT_LYRIC_INDEX, 0)
      EmitterUtil.post(EmitterConstants.EMITTER_LYRIC_UPDATE, 'Lyric Updated')
    }
  }

  async getLyricObjects(): Promise<Lyric[]> {
    const lyricStyle: LyricStyle = await AppStorage.get(StorageConstants.LYRIC_STYLE) as LyricStyle
    if(lyricStyle.mode == 1 && this.lyric.tlyric.lyric)
      return this.mergeLyrics(this.lyricObjects, this.tLyricObjects)
    else if(lyricStyle.mode == 2 && this.lyric.romalrc.lyric)
      return this.mergeLyrics(this.lyricObjects, this.rLyricObjects)
    return this.lyricObjects
  }

  async setLyricString(lyric: string) {
    this.lyric.lrc.lyric = lyric
    let tempArr = lyric.split('\n')
    this.lyricObjects = await this.parseLyricArray(tempArr)
  }

  getCurrentLyric(): string {
    return this.lyricObjects[this.currentLyricIndex].content
  }

  startInterval() {
    if(this.isUpdating) { return }
    else {
      this.isUpdating = true
      this.updateLyricInterval = setInterval(() => {
        let time: number | undefined = AppStorage.get(StorageConstants.PLAY_TIME)
        if (time) {
         let newIndex = this.updateCurrentLyricIndex(time, this.lyricObjects)
          if(newIndex != this.currentLyricIndex) {
            this.currentLyricIndex = newIndex
            AppStorage.setOrCreate(StorageConstants.CURRENT_LYRIC_INDEX, this.currentLyricIndex)
            AppStorage.setOrCreate(StorageConstants.CURRENT_LYRIC, this.lyricObjects[newIndex].content)
          }
        }
      }, 100)
    }
  }

  endInterval() {
    try {
      clearInterval(this.updateLyricInterval)
      this.isUpdating = false
    } catch (e) {

    }
  }

  /**
   * 合并歌词
   * @param baseLyrics
   * @param targetLyrics
   * @returns
   */
  private mergeLyrics(baseLyrics: Lyric[], targetLyrics: Lyric[]): Lyric[] {
    const merged: Lyric[] = []
    const targetMap = new Map<number, string>()
    targetLyrics.forEach(t => targetMap.set(t.time, t.content))
    baseLyrics.forEach(base => {
      merged.push({
        time: base.time,
        content: targetMap.has(base.time)
          ? `${base.content}\n${targetMap.get(base.time)}`
          : base.content
      })
    })
    return merged
  }


  /**
   * 解析歌词字符串数组
   * @param lyricArr 歌词字符串数组
   */
  async parseLyricArray(lyricArr: string[]): Promise<Array<Lyric>> {
    if (lyricArr.length > 1) {
      return lyricArr.map(item => {
        const match = item.match(/\[(\d+):(\d+)[.:](\d+)(?:-\d+)?\]\s*(.*)/)
        if (match) {
          const minutes = parseInt(match[1], 10) * 60 * 1000
          const seconds = parseInt(match[2], 10) * 1000
          const millisecondsPart = match[3]
          const milliseconds = parseInt(millisecondsPart, 10) * (millisecondsPart.length === 2 ? 10 : 1)
          const content = match[4]?.trim() || ""
          return { time: minutes + seconds + milliseconds, content } as Lyric
        }
        return { time: 0, content: "" }
      })
        .filter(lyric => lyric.content)
    }
    return [{ time: 0, content: '暂无歌词' }]
  }

  /**
   * 更新当前歌词索引
   * @param time 当前时间
   * @param lyricObjects 歌词对象数组
   * @returns 当前歌词索引
   */
  updateCurrentLyricIndex(time: number, lyricObjects: Lyric[]): number {
    for (let i = 0; i < lyricObjects.length; i++) {
      if (time >= lyricObjects[i].time &&
        (i === lyricObjects.length - 1 || time < lyricObjects[i + 1].time)) {
        return i
      }
    }
    return 0
  }

  /**
   * 保存Lyric String至文件
   * @param lyric
   */
  async saveLyricToFile(lyric: string, fileName: string) {
    const filesDir = FileUtils.getFilesDir()
    const cacheDir = FileUtils.getCacheDir()
    // 创建缓存并写入歌词内容
    const cachePath = cacheDir + `/${fileName}`
    try {
      let file = fileIo.openSync(cachePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE)
      await fileIo.write(file.fd, lyric)
      fileIo.closeSync(file)
      // 目标路径
      const targetDir = filesDir + '/lyric'
      const descPath = targetDir + `/${fileName}`
      if(!fileIo.accessSync(targetDir)) {
        fileIo.mkdirSync(targetDir)
      }
      await FileUtils.moveFile(cachePath, descPath)
    } catch (e) {
      LogUtil.error(TAG, 'Save lyric to file error: ' + e.message + '\n' + e.stack)
    }
  }

  /**
   * 读取本地歌词
   * @param fileName
   * @returns
   */
  async readLyric(fileName: string) {
    let lyric: string = '[00:00:00] 本地文件'
    const filesDir = FileUtils.getFilesDir()
    const lyricDir = filesDir + `/lyric/${fileName}.lrc`
    try {
      let file = fileIo.openSync(lyricDir, fileIo.OpenMode.READ_ONLY | fileIo.OpenMode.CREATE)
      let arrayBuffer = new ArrayBuffer(4096)
      let readOptions: ReadOptions = {
        offset: 0,
        length: arrayBuffer.byteLength
      }
      let readLen = fileIo.readSync(file.fd, arrayBuffer, readOptions)
      let buf = buffer.from(arrayBuffer, 0, readLen)
      lyric = buf.toString()
      fileIo.closeSync(file)
    }
    catch (e) {
      LogUtil.error(TAG, 'Read Lyric Error: ' + e.message + '\n' + e.stack)
    }
    return lyric
  }
}

const lyricUtils = new LyricUtils()
export default lyricUtils as LyricUtils
