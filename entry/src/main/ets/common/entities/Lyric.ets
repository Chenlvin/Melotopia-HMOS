/**
 * 歌词格式 time + content
 */
export interface Lyric {
  time: number
  content: string
}

interface Lrc {
  lyric: string
}

/**
 * 歌词返回结果
 */
export interface LyricResult {
  code: number
  lrc: Lrc
  tlyric: Lrc // 译
  klyric: Lrc
  romalrc: Lrc // 音
}

export const LyricResult_INITIAL: LyricResult = {
  code: 200,
  lrc: {
    lyric: ''
  },
  tlyric: {
    lyric: ''
  },
  klyric: {
    lyric: ''
  },
  romalrc: {
    lyric: ''
  },
}

export const Lrc_INITIAL: Lrc = {
  lyric: '[00:00:00] 暂无歌词'
}