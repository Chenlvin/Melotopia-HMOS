/**
 * 歌曲搜索结果
 */
import { Album } from "./Album"

export interface Artist {
  id: number
  name: string
}

// interface Album {
//   id: number
//   name: string
//   picUrl: string
// }

export interface Song {
  id: number
  name: string
  artists: Artist[]
  album: Album
  duration: number
  alias: string[]
  fee: number
}

interface Result {
  songs: Song[]
  hasMore: boolean
  songCount: number // 歌曲总数
}

export interface SongsData {
  result: Result
}

export const SongItem: Song = {
  id: 0,
  name: '',
  artists: [
    {
      id: 0,
      name: '',
    }
  ],
  album: {
    id: 0,
    name: '',
    picUrl: '',
    size: 0,
    artists: []
  },
  duration: 0,
  alias: [],
  fee: 0
}
