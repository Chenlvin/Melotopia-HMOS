import { QualityType } from "../entities/Song"


export class PlayConstants {
  /**
   * Quality Type
   */
  static readonly QUALITY: QualityType[] = ['standard', 'higher', 'exhigh', 'lossless']
  /**
   * Quality Name
   * 对应 QualityType
   */
  static readonly QUALITY_NAME: string | ResourceStr[] = [$r('app.string.standard'), $r('app.string.high'), $r('app.string.exhigh'), $r('app.string.lossless')]
  /**
   * 循环模式名称
   * 0-顺序播放, 1-单曲循环, 2-顺序循环, 3-随机播放
   */
  static readonly CYCLE_MODE: string[] = ['顺序播放', '单曲循环', '顺序循环', '随机播放']
  /**
   * 私人FM模式
   * 0-默认模式, 1-熟悉模式, 2-探索模式
   */
  static readonly PERSONAL_FM_MODE: string[] = ['DEFAULT', 'FAMILIAR', 'EXPLORE']
  /**
   * 私人FM模式名称
   * 0-默认模式, 1-熟悉模式, 2-探索模式
   */
  static readonly PERSONAL_FM_MODE_NAME: string[] = ['默认模式', '熟悉模式', '探索模式']
}