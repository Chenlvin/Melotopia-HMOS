import { Album } from "./Album"
import { Artist } from "./Song"

/**
 * 歌单创建者
 */
export interface Creator {
  userId: number
  nickname: string
  avatarUrl: string
}

/**
 * 歌单
 */
export interface PlayList {
  coverImgUrl: string
  name: string
  id: number
  playCount: number
  subscribedCount: number
  userId: number
  trackCount: number
  subscribed: boolean
  creator: Creator
  description: string
}

/**
 * 歌单结果
 */
export interface PlayListResult {
  more: boolean
  playlist: PlayList[]
}

interface OperationBody {
  code: number
  message: string
}

/**
 * 歌单操作结果
 */
export interface PlayListOperationResult {
  status: number
  body: OperationBody
}

/**
 * 歌单列表返回类
 */
export interface PlayListsResult {
  more:boolean
  playlist:PlayList[]
}

interface SearchBody {
  hasMore: boolean
  playlists: Array<PlayList>
}

/**
 * 搜索歌单结果
 */
export interface PlayListSearchResult {
  code: number
  result: SearchBody
}

/**
 * 正在播放的歌单信息
 */
export interface PlayingPlayList {
  id: number,
  count: number
}

/**
 * 歌单单曲
 */
export interface PlayListSong {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  fee: number
}

/**
 * 歌单内歌曲结果
 */
export interface PlayListSongsResult {
  songs: PlayListSong[]
}

/**
 * 每日推荐歌单内歌曲
 */
interface DailySong {
  name: string
  id: number
  dt: number
  al: Album
  ar: Artist[]
  reason: string
  fee: number
}

interface Data {
  dailySongs: DailySong[]
}

export interface DailyListSongs {
  data: Data
}

/**
 * 云盘歌单内歌曲
 */
interface CloudData {
  simpleSong: PlayListSong
}

export interface CloudResult {
  data: CloudData[]
  hasMore: boolean
}

export const PlayList_INITIAL: PlayList = {
  coverImgUrl: '',
  name: '',
  id: 0,
  playCount: 0,
  subscribedCount: 0,
  userId: 0,
  trackCount: 0,
  subscribed: false,
  creator: {
    userId: -1,
    nickname: 'null',
    avatarUrl: ''
  },
  description: ""
};

export const PlayListResult_INITIAL: PlayListResult = {
  more: false,
  playlist: [
    {
      coverImgUrl: '',
      name: '',
      id: 0,
      playCount: 0,
      subscribedCount: 0,
      userId: 0,
      trackCount: 0,
      subscribed: false,
      creator: {
        userId: -1,
        nickname: '',
        avatarUrl: ''
      },
      description: ''
    }
  ]
};

export const CloudResult_INITIAL: CloudResult = {
  data: [],
  hasMore: false
}

export const PlayListOperationResult_INITIAL: PlayListOperationResult = {
  status: 200,
  body:
  {
    code: -1,
    message: ''
  }
}
