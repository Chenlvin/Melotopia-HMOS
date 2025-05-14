import { ArtistInfo, ArtistItem, ArtistsResult } from "../common/entities/Artists"
import commonRequest from "../common/utils/request/RequestUtil"

/**
 * 获取歌手信息
 * @param id
 * @returns
 */
export const getArtistInfo = async (id: number): Promise<ArtistInfo> => {
  return commonRequest<ArtistInfo>({
    url: '/artists',
    params: { id }
  })
}

/**
 * 搜索歌手列表
 * @param keyword
 * @returns
 */
export const searchArtists = async (keywords: string, limit: number = 20): Promise<ArtistItem[]> => {
  const result = await commonRequest<ArtistsResult>({
    url: '/search',
    params: { keywords, limit, type: 100 }
  })
  return result.result.artists ?? []
}

