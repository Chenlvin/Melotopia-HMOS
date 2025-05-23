import { COMMENT_TYPE } from "./Enum";
import { DjRadio } from "../entities/DjRadio";
import { PlayList } from "../entities/PlayList";
import { Album } from "../entities/Album";
import { Artist } from "../entities/Song";

/**
 * 歌单详情页参数
 */
export interface PlayListPageParam {
  playList: PlayList
  isShowHeart: boolean
  useTimestamp: boolean
}

/**
 * 网页参数
 */
export interface WebPageParam {
  title: string | ResourceStr
  url: string
}

/**
 * 歌手信息参数
 */
export interface ArtistParam {
  artist: Artist
}

/**
 * DjRadio信息参数
 */
export interface DjRadioParam {
  djRadio: DjRadio
}

/**
 * 专辑信息参数
 */
export interface AlbumParam {
  album: Album
}

/**
 * 评论页参数
 */
export interface CommentParam {
  id: number
  name: string
  type: COMMENT_TYPE
}

/**
 * 通用参数
 */
export interface CommonParam<T> {
  pageName: string
  param: T
  remove: boolean
}