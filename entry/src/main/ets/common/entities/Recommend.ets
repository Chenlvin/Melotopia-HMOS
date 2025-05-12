import { Album } from "./Album"

interface Artist {
  name: string
  id: number
}

interface SongInfo {
  id: number
  name: string
  ar: Artist[]
  dt: number
  al: Album
  fee: number
}

interface ResultData {
  songInfo: SongInfo
}

/**
 * 心动模式
 */
export interface HeartMode {
  code: number
  data: ResultData[]
}

/**
 * 推荐歌单信息
 */
export interface PersonalListItem {
  id: number
  type: number
  name: string
  copywriter: string
  picUrl: string
  playCount: number
  trackCount: number
}

/**
 * 推荐歌单
 */
export interface Personalized {
  hasTaste: boolean
  code: number
  result: PersonalListItem[]
}

/**
 * 排行榜单个信息
 */
export interface TopListItem {
  id: number
  name: string
  trackCount: number
  updateFrequency: string // “更新xx首”
  coverImgUrl: string
  description: string
  playCount: number
  subscribedCount: number
}

/**
 * 排行榜
 */
export interface TopList {
  code: number
  list: TopListItem[]
}