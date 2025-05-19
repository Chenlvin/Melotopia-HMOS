import { MCMediaCache } from "@sj/mediacache";
import { getCacheSet, getCookie } from "../../functions/common/get";

export default class AudioCacheUtils {
  static async init() {
    const cacheSet = await getCacheSet()
    MCMediaCache.setLogEnabled(false)
    MCMediaCache.setRequestHandler(async (request) => {
      let cookie = await getCookie()
      request.setHeader('cookie', cookie)
    })
    MCMediaCache.setAssetIdentifierPreprocessor(async (url) => {
      url = url.split('?')[0]
      let start: number = url.lastIndexOf("/")
      let end: number = url.lastIndexOf(".")
      let cacheName: string = url.substring(start + 1, end) + '-' + url.substring(end + 1)
      return cacheName
    })
    MCMediaCache.cacheConfig.maxDiskSize = cacheSet.songCacheMaxSize

    await MCMediaCache.prepare(getContext())
  }

  static async getProxyUrl(url: string) {
    return await MCMediaCache.proxy(url)
  }

  static async clearAll() {
    await MCMediaCache.removeCaches()
  }

  static async getTotalCachedSize() {
    const size = await MCMediaCache.totalCacheSize()
    return size
  }
}