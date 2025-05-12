import { QualityType, SongDownload } from "../common/entities/Song"
import commonRequest from "../common/utils/request/RequestUtil"

interface SongUrlResponse {
  data: SongDownload
}
/**
 * 获取音乐地址
 * @param songId 歌曲ID
 * @param quality 音质
 * @param isLogged 是否登录
 * @returns data:SongDownload
 */
export const getDownloadInfo = async (
  id: string,
  quality: QualityType,
  isLogged: boolean
): Promise<SongDownload> => {
  // const rootUrl = await getApiUrl()
  // const url: string = isLogged ?
  //   `${rootUrl}/song/url/v1?id=${songId}&level=${quality}` :
  //   `${rootUrl}/song/url?id=${songId}`
  // const request = new HttpRequest(url)
  // try {
  //   const data = await request.Request()
  //   const dataGot: SongDownload = isLogged ? data.result as SongDownload :
  //     { data: data.result["data"] }
  //   return dataGot
  // } catch (e) {
  //   LogUtil.error('Error fetching download info: ' + JSON.stringify(e))
  //   throw new Error('获取歌曲链接失败')
  // }
  if(isLogged) {
    return commonRequest({
      url: '/song/url/v1',
      params: { id, level: quality }
    })
  }

  const request = await commonRequest<SongUrlResponse>({
    url: '/song/url',
    params: { id, noCookie: true }
  })

  return request.data
}