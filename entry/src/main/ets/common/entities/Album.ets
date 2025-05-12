import { PlayListSong } from "./PlayList"
import { Artist } from "./Song"

interface AlbumDetail {
  company: string
  picUrl: string
  description: string
  name: string
  id: number
}

/**
 * 专辑详细信息
 */
export interface AlbumInfoResult {
  code: number
  resourceState: boolean
  songs: PlayListSong[]
  album: AlbumDetail
}

/**
 * 专辑
 */
export interface Album {
  artists: Artist[]
  picUrl: string
  name: string
  id: number
  size: number
}

/**
 * 收藏专辑结果
 */
export interface SubAlbumResult {
  data: Album[]
}

interface SearchResult {
  albums: Album[]
}

/**
 * 搜索专辑结果
 */
export interface AlbumSearchResult {
  result: SearchResult
}

export const AlbumInfoResult_INITIAL: AlbumInfoResult = {
  code: 200,
  resourceState: false,
  songs: [],
  album: {
    company: '',
    picUrl: '',
    description: '',
    name: '',
    id: 0
  }
}

export const SubAlbumResult_INITIAL: SubAlbumResult = {
  data: []
}

export const Album_INITIAL: Album = {
  artists: [],
  picUrl: "",
  name: "",
  id: 0,
  size: 0
}

export const AlbumSearchResult_INITIAL: AlbumSearchResult = {
  result: {
    albums: []
  }
}