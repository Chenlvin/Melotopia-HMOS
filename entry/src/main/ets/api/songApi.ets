import { LogUtil } from "@pura/harmony-utils"
import { PlayConstants } from "../common/constants/PlayConstants"
import { StorageConstants } from "../common/constants/StorageConstants"
import { HeartMode } from "../common/entities/Recommend"
import { PlayQueue } from "../common/model/PlayQueue"
import { QualityType, Song, SongDetail, Song_INITIAL, SongPlayResult, SongSearchResult } from "../common/entities/Song"
import { User } from "../common/entities/User"
import PlayQueueUtils from "../common/utils/play/PlayQueueUtils"
import { DailySongRes } from "./playListApi"
import commonRequest from "../common/utils/request/RequestUtil"
import { DailyListSongs } from "../common/entities/PlayList"

interface CheckValiableResponse {
  success: boolean
}
/**
 * 音乐是否可用
 */
export const checkMusic = async (id: number): Promise<boolean> => {
  try {
    const response = await commonRequest<CheckValiableResponse>({
      url: '/check/music',
      params: { id }
    })
    return response.success
  } catch (e) {
    return false
  }
}

export interface SearchReturn {
  list: Array<Song>
  hasMore: boolean
  songCount: number
}
/**
 * 搜索歌曲
 * @param keywords
 * @param offset
 * @param limit
 */
export const searchSongs = async (
  keywords: string,
  offset: number,
  limit: number = 30
): Promise<SearchReturn> => {
  const response = await commonRequest<SongSearchResult>({
    url: '/search',
    params: { keywords, offset, limit, noCookie: true }
  })

  let searchReturn: SearchReturn = {
    list: response.result.songs,
    hasMore: response.result.hasMore,
    songCount: response.result.songCount
  }
  return searchReturn
}

/**
 * 获取歌曲播放Url
 */
export const getSongUrl = async (
  id: number,
  quality: QualityType,
  isLogged: boolean
): Promise<SongPlayResult> => {
  return commonRequest({
    url: '/song/url/v1',
    params: { id, level: quality }
  })
}

/**
 * 获取歌曲图片Url
 * @param id
 * @returns string
 */
export const getSongPicUrl = async (ids: number): Promise<string> => {
  const response = await commonRequest<SongDetail>({
    url: '/song/detail',
    params: { ids }
  })
  return response.songs[0].al.picUrl ?? ''
}

/**
 * 获取每日推荐歌单
 * @param useCookie
 * @returns
 */
export const getDailySongs = async (useCookie: boolean = true): Promise<Array<DailySongRes>> => {
  let list: Array<DailySongRes> = []
  const response = await commonRequest<DailyListSongs>({
    url: '/recommend/songs',
    params: useCookie ? { } : { noCookie: true }
  })
  if(response.data) {
    for (let song of response.data.dailySongs) {
      list.push({
        song: {
          id: song.id,
          name: song.name,
          artists: song.ar,
          album: song.al,
          duration: song.dt,
          alias: [],
          fee: song.fee
        },
        reason: song.reason,
        picUrl: song.al.picUrl
      })
    }
  }
  return list
}

interface LikeListResponse {
  ids: string[]
}
/**
 * 获取喜欢列表(songId 数组)
 * @param uid
 * @returns
 */
export const getLikeList = async (): Promise<string[]> => {
  let user = await AppStorage.get(StorageConstants.USER) as User
  let list:Array<string> = []
  const response = await commonRequest<LikeListResponse>({
    url: '/likelist',
    params: { uid: user.data.account.id, timestamp: new Date().getTime() }
  })
  try {
    const dataGot: string[] = response.ids as string[]
    list = dataGot
  } catch (e) {
  } finally {
    AppStorage.setOrCreate(StorageConstants.USER_LIKELIST, list)
    return list
  }
}

interface LikeMusicResponse {
  code: number
}
/**
 * 喜欢歌曲
 * @param id
 * @returns
 */
export const likeMusic = async (id: number): Promise<boolean> => {
  const response = await commonRequest<LikeMusicResponse>({
    url: '/like',
    params: { id, timestamp: new Date().getTime() }
  })
  return response.code === 200 ? true : false
}

/**
 * 心动模式
 * @param id - 歌曲id
 * @param pid - 歌单id
 */
export const setHeartMode = async (id: number, pid: number): Promise<void> => {
  let queue: Array<PlayQueue> = []
  let tempSong: Song
  const response = await commonRequest<HeartMode>({
    url: '/playmode/intelligence/list',
    params: { id, pid }
  })
  for(let item of response.data) {
    tempSong = {
      id: item.songInfo.id,
      name: item.songInfo.name,
      artists: item.songInfo.ar,
      album: item.songInfo.al,
      duration: item.songInfo.dt,
      alias: [],
      fee: item.songInfo.fee
    }
    queue.push({
      playmode: 1,
      song: tempSong,
      fileName: '',
      picUrl: item.songInfo.al.picUrl ?? ''
    })
  }
  await PlayQueueUtils.cleanQueue()
  await PlayQueueUtils.queueAdd_array(queue)
}

interface PersonalFmSongResult {
  code: number
  data: Song[]
}
/**
 * 获取私人FM歌曲
 */
export const getPersonalFmSong = async (mode: number): Promise<Song> => {
  const response = await commonRequest<PersonalFmSongResult>({
    url: '/personal/fm/mode',
    params: { mode: PlayConstants.PERSONAL_FM_MODE[mode], timestamp: new Date().getTime() }
  })
  if(response.code == 200) {
    let dataGot = response.data[0] as Song
    return dataGot
  } else return Song_INITIAL
}