import { Album } from "./Album"

/**
 * 歌手
 */
export interface Artist {
  id: number
  name: string
}

/**
 * 单曲
 */
export interface Song {
  id: number
  name: string
  artists: Artist[]
  album: Album
  duration: number
  alias: string[]
  fee: number
}

interface SearchResultBody {
  songs: Song[]
  hasMore: boolean
  songCount: number // 歌曲总数
}

/**
 * 歌曲搜索结果
 */
export interface SongSearchResult {
  result: SearchResultBody
}

interface Al {
  picUrl:string
}

interface SongDetailItem {
  al: Al
}

/**
 * SongDetail
 * 歌曲详细信息
 */
export interface SongDetail {
  songs: SongDetailItem[]
}

/**
 * 音质
 */
export type QualityType = 'standard' | 'higher' | 'exhigh' | 'lossless' | 'hires' | 'jyeffect' | 'sky' | 'dolby' | 'jymaster'

/**
 * 歌曲下载
 */
export interface SongDownloadItem {
  id: number
  url: string
  size: number
  type: string
  level: QualityType
}

/**
 * 歌曲Url
 */
export interface SongDownload {
  data: SongDownloadItem[]
}

interface SongPlayData {
  id: number
  url: string
  time: number
}

/**
 * 歌曲播放
 */
export interface SongPlayResult {
  data: SongPlayData[]
}

/**
 * 本地歌曲
 */
export interface LocalSong {
  id: number
  songId: number
  name: string
  artists: string
  picFile: string
  songFile: string
  lyricFile: string
}

export const LocalSong_INITIAL: LocalSong = {
  id: -1,
  songId: -1,
  name: "",
  artists: "",
  picFile: "",
  songFile: "",
  lyricFile: "",
}

export const SongPlay_INITIAL: SongPlayResult = {
  data: [{
    id: -1,
    url: '',
    time: -1
  }]
}

export const SongDownload_INITIAL: SongDownload = {
  data: [{
    id: 0,
    url: '',
    size: 0,
    type: '',
    level: 'lossless',
  }],
};

export const SongDetail_INITIAL: SongDetail = {
  songs: [
    {
      al: {
        picUrl: ''
      }
    }
  ]
};

export const Song_INITIAL: Song = {
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
