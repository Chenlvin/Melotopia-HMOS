export type QualityType = 'standard' | 'higher' | 'exhigh' | 'lossless' | 'hires' | 'jyeffect' | 'sky' | 'dolby' | 'jymaster'

export interface SongDownloadItem {
  id: number
  url: string
  size: number
  type: string
  level: QualityType
}

export interface SongDownload {
  data: SongDownloadItem[]
}

export const SongDownloadClass: SongDownload = {
  data: [{
    id: 0,
    url: '',
    size: 0,
    type: '',
    level: 'lossless',
  }],
};
