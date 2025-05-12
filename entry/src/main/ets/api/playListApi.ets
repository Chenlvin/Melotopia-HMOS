import { ToastUtil } from "@pura/harmony-utils"
import {
  CloudResult,
  PlayList, PlayListOperationResult,
  PlayListResult,
  PlayListSearchResult,
  PlayListSong,
  PlayListSongsResult} from "../common/entities/PlayList"
import { Song } from "../common/entities/Song"
import { User, User_INITIAL } from "../common/entities/User"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import { StorageConstants } from "../common/constants/StorageConstants"
import commonRequest from "../common/utils/request/RequestUtil"
import { Personalized, PersonalListItem } from "../common/entities/Recommend"

export interface PlayListsResult {
  more:boolean
  playlist:PlayList[]
}
/**
 * 获取用户歌单列表
 * @param offset - 偏移量
 * @returns list
 */
export const getPlayLists = async (offset: number): Promise<PlayListsResult> => {
  let list: PlayList[] = new Array()
  const user = await PreferencesUtils.getPreferenceValue<User>(StorageConstants.USER_PREF, StorageConstants.USER, User_INITIAL)
  if(user.data.account.id === 0) {
    return { more: false, playlist: [] }
  }
  const response = await commonRequest<PlayListResult>({
    url:'/user/playlist',
    params: { uid: user.data.account.id, offset, timestamp: new Date().getTime() }
  })
  list = response.playlist
  AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, list)
  PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, list)
  return response
}

/**
 * 获取歌单内歌曲列表
 * @param listId 歌单ID
 * @param trackCount 歌曲总数
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export const getPlayListSongs = async (
  id: number,
  limit: number,
  offset: number,
  usetimestamp: boolean = true
): Promise<PlayListSong[]> => {
  const result = await commonRequest<PlayListSongsResult>({
    url: '/playlist/track/all',
    params: { id, limit, offset, timestamp: new Date().getTime() }
  })
  return result.songs
}

/**
 * 歌单操作
 */
type OperationType = 'add' | 'del'
/**
 * 向歌单添加/删除歌曲
 * @param op - 操作 add/del
 * @param pid - 歌单id
 * @param tracks - 歌曲id(多个用,隔开)
 */
export const PlayListOperation = async (
  op: OperationType,
  pid:number,
  tracks:number
): Promise<boolean> => {
  const result = await commonRequest<PlayListOperationResult>({
    url: '/playlist/tracks',
    params: { op: op, pid, tracks, timestamp: new Date().getTime() }
  })
  if(result.body.code === 200) return true
  return false
}

export interface DailySongRes {
  song: Song
  reason: string
  picUrl: string
}
/**
 * 获取云盘歌曲列表
 * @param offset 偏移
 * @returns list 歌曲列表
 */
export const getCloudList = async (offset: number): Promise<CloudResult> => {
  return commonRequest({
    url: '/user/cloud',
    params: { limit: 200, offset }
  })
}

/**
 * 搜索歌单
 * @returns list
 */
export const searchPlayLists = async (keywords: string, offset:number): Promise<PlayListsResult> => {
  const response = await commonRequest<PlayListSearchResult>({
    url: '/search',
    params: { keywords, offset, limit: 20, type: 1000 }
  })
  const result: PlayListsResult = {
    more: response.result.hasMore,
    playlist: response.result.playlists
  }
  return result
}

interface subResponse {
  code: number
  message: string
}
/**
 * 收藏/取消收藏歌单
 * @param mode - 1:收藏, 2:取消收藏
 * @returns
 */
export const subscribePlayList = async (id: number, mode: number): Promise<boolean> => {
  const response = await commonRequest<subResponse>({
    url: '/playlist/subscribe',
    params: { t: mode, id, timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response.message)
  return false
}

/**
 * Get personalized list
 * @returns Array<PersonalListItem>
 */
export const getPersonalizedList = async (): Promise<Array<PersonalListItem>> => {
  const request = await commonRequest<Personalized>({
    url: '/personalized',
    params: { timestamp: new Date().getTime() }
  })
  AppStorage.setOrCreate(StorageConstants.PERSONALIZED_LIST, request.result)
  PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.PERSONALIZED_LIST, request.result)
  return request.result
}

interface delResponse {
  code: number
  message: string
}

/**
 * 删除歌单
 * @param pid
 */
export const deletePlayList = async (id: number): Promise<boolean> => {
  const response = await commonRequest<delResponse>({
    url: '/playlist/delete',
    params: { id, timestamp: new Date().getTime() }
  })
  if(response.code === 200) return true
  ToastUtil.showToast(response?.message)
  return false
}

/**
 * 创建歌单 —— 不可用
 * @param name
 * @param isPrivacy
 */
export async function createPlayList(name: string, isPrivacy: boolean) {
  //   const url: string = `${rootUrl}/playlist/create?name=${encodeURIComponent(name)}${isPrivacy ? '&privacy=10' : ''}&timestamp=${new Date().getTime()}`
}