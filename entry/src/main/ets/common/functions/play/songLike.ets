import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayListOperation } from "../../../api/playListApi"
import { getLikeList, likeMusic } from "../../../api/songApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { PlayList } from "../../entities/PlayList"
import { Song } from "../../entities/Song"

const TAG = '[songLike] '

/**
 * 判断当前歌曲是否被喜欢
 * @param sid
 */
export async function isThisSongLiked(sid: number) {
  let isLiked: boolean = false
  try {
    let likelist: string[] = await AppStorage.get(StorageConstants.USER_LIKELIST) as string[]
    if(likelist.length != 0) {
      isLiked = likelist.map(Number).includes(sid)
    }
  } catch (e) {
    LogUtil.error(TAG, 'isThisSongLiked Error: ' + e.message)
  } finally {
    AppStorage.setOrCreate(StorageConstants.ISLIKED, isLiked)
  }
}

/**
 * 喜欢当前歌曲
 */
export async function likeThisSong() {
  try {
    let isLogged: boolean = AppStorage.get(StorageConstants.IS_LOGGED) as boolean
    let isLiked: boolean = AppStorage.get(StorageConstants.ISLIKED) as boolean
    if (!isLogged) {
      return
    } else if(!isLiked) { // 未喜欢
      let currentSong = await AppStorage.get(StorageConstants.PLAY_SONG) as Song
      const result = await likeMusic(currentSong.id)
      AppStorage.setOrCreate(StorageConstants.ISLIKED, result)
      getLikeList()
      ToastUtil.showToast(result ? '已收藏至【我喜欢的音乐】' : '收藏失败')
    } else { // 已喜欢
      let currentSong = await AppStorage.get(StorageConstants.PLAY_SONG) as Song
      let userPlayLists = await AppStorage.get(StorageConstants.USER_PLAYLISTS) as Array<PlayList>
      const result = await PlayListOperation('del', userPlayLists[0].id, currentSong.id)
      AppStorage.setOrCreate(StorageConstants.ISLIKED, !result)
      getLikeList()
      ToastUtil.showToast(result ? '取消喜欢当前歌曲' : '取消喜欢失败')
    }
  } catch (e) {
    LogUtil.error(TAG, 'likeThisSong Error: ' + e.message)
  }
}
