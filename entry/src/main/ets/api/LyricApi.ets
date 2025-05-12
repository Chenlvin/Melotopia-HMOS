import { LyricResult } from "../common/entities/Lyric";
import { getApiUrl } from "../common/functions/common/get";
import commonRequest from "../common/utils/request/RequestUtil";

/**
 * 获取歌词
 * @param id - 歌曲id
 * @returns - string[]
 */
export const getLyric = async (id: number): Promise<LyricResult> => {
  return commonRequest({
    url: '/lyric',
    params: { id, noCookie: true }
  })
}

/**
 * 获取歌词完整string
 * @param id
 * @return
 */
export const getLyricString = async (id: number): Promise<string> => {
  const response = await commonRequest<LyricResult>({
    url: '/lyric',
    params: { id, noCookie: true }
  })
  return response.code === 200 ? response.lrc.lyric : '[00:00:00] 暂无歌词'
}