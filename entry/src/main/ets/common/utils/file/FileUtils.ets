import fileIo from '@ohos.file.fs'
import {  FileUtil, LogUtil, PreviewUtil, ToastUtil } from '@pura/harmony-utils'
import fs from '@ohos.file.fs'
import { Environment, fileUri, statfs } from '@kit.CoreFileKit'
import { picker } from '@kit.CoreFileKit'
import { BusinessError } from '@kit.BasicServicesKit'
import RelationalStoreUtils from '../data/RelationalStoreUtils'
import { JSON } from '@kit.ArkTS'
import { fetchSongInfo, getArtists } from '../../functions/common/convert'
import { getContext_ } from '../system/AppUtils'
import { LocalSong } from '../../entities/Song'

/**
 * 文件管理
 */
const TAG = '[FileUtils] '

class FileUtils {
  getFilesDir() {
    return getContext_().filesDir
  }

  getCacheDir() {
    return getContext_().cacheDir
  }

  async getFileName(): Promise<Array<string>> {
    let list = await fileIo.listFile(getContext_().filesDir, {
      filter: {
        suffix: ['.mp3', '.MP3', '.flac', '.FLAC'],
      }
    })
    return list
  }

  /**
   * 是否存在本地文件
   * @param fileName
   * @returns string - fdPath
   */
  async accessLocalFile(fileName: string): Promise<string> {
    const fileType: Array<string> = ['flac', 'FLAC', 'mp3', 'MP3']
    for(let type of fileType) {
      let filePath = getContext_().filesDir + `/${fileName}.${type}`
      if(await(FileUtil.access(filePath))) {
        let file = await fileIo.open(filePath)
        let fdPath = 'fd://' + file.fd
        return fdPath
      }
    }
    return ''
  }

  async deleteFile(localSongs: LocalSong[]) {
    try {
      let successCount = 0
      for (const localSong of localSongs) {
        try {
          RelationalStoreUtils.deleteSong(localSong.id)
          await FileUtil.unlink(getContext_().filesDir + `/${localSong.songFile}`)
          if(localSong.songId != 0) {
            await FileUtil.unlink(getContext_().filesDir + `/pic/${localSong.songId}.jpg`)
            await FileUtil.unlink(getContext_().filesDir + `/lyric/${localSong.songId}.lrc`)
          }
          successCount++
        } catch (e) {
          LogUtil.error(TAG, `删除文件 ${localSong.songFile} 失败: ${e.stack}`)
        }
      }
      ToastUtil.showToast(`删除了 ${successCount}/${localSongs.length} 个文件`)
    } catch (e) {
      LogUtil.error(TAG, `Delete files error: ${JSON.stringify(e)}`)
    }
  }


  async getFileUri(fileName:string): Promise<fileUri.FileUri | null> {
    try {
      let uri = FileUtil.getFileUri(getContext_().filesDir + `/${fileName}`)
      return uri
    } catch (e) {
      LogUtil.error(TAG, '获取文件Uri失败: ' + e.message())
      return null
    }
  }

  async moveFile(from:string, to:string) {
    try {
      FileUtil.moveFile(from, to, 0)
    } catch (e) {
      LogUtil.error(TAG, '移动文件时出错 move file error: ' + e.message())
    }
  }

  async saveFile(localSongs: LocalSong[], type: 'song' | 'lyric' | 'img' | 'all' = 'song') {
    try {
      let filePicker = new picker.DocumentViewPicker()
      let saveOption = new picker.DocumentSaveOptions()
      let empty: string[] = []
      saveOption.newFileNames = empty

      if (type === 'song' || type === 'all') {
        saveOption.newFileNames.push(...localSongs.map(song => song.songFile.replace(/[#￥%$]/g, '')))
      }
      if (type === 'lyric' || type === 'all') {
        saveOption.newFileNames.push(...localSongs.map(song => `${song.songFile.replace(/[#￥%$]/g, '').replace(/\.[^.]+$/, '')}.lrc`))
      }
      if (type === 'img' || type === 'all') {
        saveOption.newFileNames.push(...localSongs.map(song => `${song.songFile.replace(/[#￥%$]/g, '').replace(/\.[^.]+$/, '')}.jpg`))
      }
      filePicker.save(saveOption).then((uris) => {
        const songCount = localSongs.length
        uris.forEach(async (uri, index) => {
          try {
            let srcPath: string
            // 计算实际歌曲索引和文件类型
            if (type === 'all') {
              const fileTypeIndex = Math.floor(index / songCount)
              const songIndex = index % songCount

              switch(fileTypeIndex) {
                case 0: // 歌曲文件
                  srcPath = getContext_().filesDir + `/${localSongs[songIndex].songFile}`
                  break
                case 1: // 歌词文件
                  srcPath = getContext_().filesDir + `/lyric/${localSongs[songIndex].songId}.lrc`
                  break
                case 2: // 图片文件
                  srcPath = getContext_().filesDir + `/pic/${localSongs[songIndex].songId}.jpg`
                  break
                default:
                  return
              }
            } else {
              // 原有类型处理
              const songIndex = Math.min(index, songCount - 1)
              srcPath = getContext_().filesDir + (
                type === 'song' ? `/${localSongs[songIndex].songFile}` :
                  type === 'lyric' ? `/lyric/${localSongs[songIndex].songId}.lrc` :
                    `/pic/${localSongs[songIndex].songId}.jpg`
              )
            }

            let descFile = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
            await fs.copyFile(srcPath, descFile.fd)
            fs.closeSync(descFile.fd)
          } catch (err) {
            const errorIndex = type === 'all' ? index % songCount : index
            LogUtil.error(TAG, `文件 ${localSongs[errorIndex]?.songFile} 保存失败: ${err.message}`)
          }
        })
        ToastUtil.showToast(`保存了 ${uris.length} 个文件`)
      }).catch((err: Error) => {
        LogUtil.error(TAG, 'File Picker 出错: ' + err.message)
      })
    } catch (e) {
      LogUtil.error(TAG, '保存文件出错: ' + e.message())
    }
  }


  async previewFile(fileName: string) {
    let uri = FileUtil.getUriFromPath(getContext_().filesDir + `/${fileName}`)
    let info = PreviewUtil.generatePreviewInfo(uri)
    PreviewUtil.openPreview(info).catch((error: BusinessError) => {
      LogUtil.error(TAG, 'preview file error: ' + error.message)
    })
  }

  async removeCache(): Promise<boolean> {
    try {
      await FileUtil.rmdir(getContext_().cacheDir)
      return true
    } catch (e) {
      LogUtil.error(TAG, e.message())
      ToastUtil.showToast('清除缓存失败')
    }
    return false
  }

  getCacheSize(): number {
    try {
      let size = FileUtil.getFileDirSize(getContext_().cacheDir)
      return size
    } catch (e) {
      LogUtil.error(TAG, '获取缓存大小失败: ' + e.message())
      return -1
    }
  }

  async saveFilesToDirectory(uris: string[]) {
    let result: number = 0
    try {
      for (const uri of uris) {
        let fileUriObject = new fileUri.FileUri(uri)
        if(await FileUtil.access(getContext_().filesDir + `/${fileUriObject.name}`)) {
          continue
        }
        let file = fs.openSync(uri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        let file2 = fs.openSync(getContext_().filesDir + `/${fileUriObject.name}`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE)
        fs.copyFileSync(file.fd, file2.fd)
        fs.closeSync(file)
        fs.closeSync(file2)
        let song = await fetchSongInfo(fileUriObject.name)
        let localSong: LocalSong = {
          id: 0,
          songId: 0,
          name: song.name,
          artists: getArtists(song.artists),
          picFile: "",
          songFile: fileUriObject.name,
          lyricFile: "",
        }
        await RelationalStoreUtils.addSong(localSong)
        result ++
      }
    } catch (e) {
      ToastUtil.showToast('上传失败')
    } finally {
      return result
    }
  }

  getUserDir() {
    let dir: string = ''
    try {
      if (canIUse('SystemCapability.FileManagement.File.Environment.FolderObtain')) {
        dir = Environment.getUserDownloadDir()
      } else {
        dir = getContext_().filesDir
      }
    } catch (e) {
      ToastUtil.showToast('获取公共目录失败: ' + e.message)
    } finally {
      return dir
    }
  }

  async getSongCacheSize(): Promise<number> {
    try {
      let path = getContext_().filesDir + '/mc_media_cache'
      let sizeTotal = statfs.getTotalSizeSync(path)
      let sizeFree = statfs.getFreeSizeSync(path)
      return sizeTotal - sizeFree
    } catch (e) {
      LogUtil.error(TAG, 'getSongCacheSize Error: ' + e.message)
      return 0
    }
  }
}

const fileUtils = new FileUtils()
export default fileUtils as FileUtils