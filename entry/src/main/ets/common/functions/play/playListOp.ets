import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../../constants/StorageConstants"
import { PlayQueue } from "../../model/PlayQueue"
import { PlayingPlayList, PlayListSong } from "../../entities/PlayList"
import PlayQueueUtils from "../../utils/play/PlayQueueUtils"
import { playQueue } from "./playControl"

const TAG = '[playListOp] '

export async function playListToQueue(playlist: PlayListSong[], index: number) {
  try {
    if(playlist.length === 0) return
    let queue: PlayQueue[] = playlist.map((item): PlayQueue => ({
      playmode: 2,
      song: {
        id: item.id,
        name: item.name,
        artists: item.ar,
        album: item.al,
        duration: item.dt,
        fee: item.fee,
        alias: []
      },
      fileName: '',
      picUrl: item.al.picUrl
    }))
    await PlayQueueUtils.cleanQueue()
    await PlayQueueUtils.queueAdd_array(queue)
    playQueue(index)
  } catch (e) {
    ToastUtil.showToast('播放失败: ' + e.message)
    LogUtil.error(TAG, 'playlist to queue error: ' + e.stack)
  }
}

export function cleanLastPlayInfo() {
  const playInfo: PlayingPlayList = {
    id: -1,
    count: -1
  }
  AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)
}