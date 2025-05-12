import { Song } from "./Song"

/**
 * 电台节目
 */
export interface DjRadioProgram {
  mainSong: Song
  dj: Dj
  radio: DjRadio
  coverUrl: string
}

/**
 * 电台节目返回结果
 */
export interface DjProgramResult {
  count: number
  code: number
  more: boolean
  programs: DjRadioProgram[]
}

/**
 * 推荐电台
 */
export interface RecommendDjRadio {
  id: number
  name: string
  picUrl: string
  categoryId: number
  category: string
  rcmdtext: string
  playCount: number
  dj: Dj
  copywriter: string
  buyed: boolean
}

/**
 * 推荐电台结果
 */
export interface DjRecommendResult {
  djRadios: RecommendDjRadio[]
}

/**
 * 电台作者/DJ
 */
export interface Dj {
  avatarUrl: string
  userId: number
  nickname: string
  backgroundUrl: string
}

/**
 * 电台
 */
export interface DjRadio {
  dj: Dj
  category: string
  secondCategory: string
  buyed: boolean
  lastProgramName: string // 最新歌曲的标题
  intervenePicUrl: string
  subCount: number
  programCount: number
  picUrl: string
  lastProgramId: number
  desc: string // 简介
  name: string
  id: number
}

/**
 * Sublist 电台返回类
 */
export interface DjResult {
  code: number
  djRadios: DjRadio[]
  count: number
  hasMore: boolean
}

export const DjRadio_INITIAL: DjRadio = {
  dj: {
    avatarUrl: '',
    userId: 0,
    nickname: '',
    backgroundUrl: ''
  },
  category: "",
  secondCategory: "",
  buyed: false,
  lastProgramName: "",
  intervenePicUrl: "",
  subCount: 0,
  programCount: 0,
  picUrl: "",
  lastProgramId: 0,
  desc: "",
  name: "",
  id: 0
}

export const RecommendDjRadio_INITIAL: RecommendDjRadio = {
  id: 0,
  name: "",
  picUrl: "",
  categoryId: 0,
  category: "",
  rcmdtext: "",
  playCount: 0,
  dj: {
    avatarUrl: '',
    userId: 0,
    nickname: '',
    backgroundUrl: ''
  },
  copywriter: "",
  buyed: false
}