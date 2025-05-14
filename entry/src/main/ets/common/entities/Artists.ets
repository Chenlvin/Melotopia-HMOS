import { PlayListSong } from "./PlayList"

/**
 * 歌手
 */
export interface ArtistItem {
  id: number,
  name: string,
  picUrl: string
}

interface ArtistBody {
  artistCount: number
  artists: ArtistItem[]
}

interface ArtistInfoBody {
  briefDesc: string // 简介
  picUrl: string
  alias: string[] //别名
  name: string
  id: number
}

/**
 * 歌手详细信息
 */
export interface ArtistInfo {
  artist: ArtistInfoBody
  hotSongs: PlayListSong[]
  code: number
  more: boolean
}

/**
 * 歌手请求
 */
export interface ArtistsResult {
  result: ArtistBody
}

export const ArtistInfo_INITIAL: ArtistInfo = {
  artist: {
    briefDesc: '',
    picUrl: '',
    alias: [],
    name: '',
    id: 0
  },
  hotSongs: [],
  code: 0,
  more: false
}