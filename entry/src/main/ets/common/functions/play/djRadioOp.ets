import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { putDjRadioInQueue } from "../../../api/djApi"
import { StorageConstants } from "../../constants/StorageConstants"
import { PlayingPlayList } from "../../entities/PlayList"
import { playQueue } from "./playControl"

const TAG = '[playListOp] '
export async function djRadioToQueue(id: number, count: number, currentIndex: number = 0) {
  try {
    AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, true)
    const lastPlayInfo = await AppStorage.get(StorageConstants.LAST_PLAYED_LIST) as PlayingPlayList
    if(lastPlayInfo.id != -1 && lastPlayInfo.id == id && lastPlayInfo.count == count) {
      playQueue(currentIndex)
    } else {
      let limit = 100
      await putDjRadioInQueue(id, limit, limit, currentIndex < 50 ? 0 : currentIndex - 25, true)
      playQueue(currentIndex < 50 ? currentIndex : 25)
      await putDjRadioInQueue(id, count, 400, limit, false)
    }
  } catch (e) {
    LogUtil.error(TAG, '' + e.message)
    ToastUtil.showToast('播放播客出错')
  } finally {
    // const playInfo: PlayingPlayList = {
    //   id: id,
    //   count: count
    // }
    // AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
    AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, false)
  }
}