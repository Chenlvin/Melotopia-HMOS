import { LogUtil } from "@pura/harmony-utils";
import { StorageConstants } from "../../constants/StorageConstants";
import { CacheSet, CacheSet_INITIAL } from "../../model/Settings";
import { Artist } from "../../entities/Song";
import commonRequest from "../../utils/request/RequestUtil";
import { getArtists } from "./convert";

const TAG = '[GET ]'
/**
 * 获取API Url
 * （根据用户设置）
 * @returns string - ApiUrl
 */
export async function getApiUrl(): Promise<string | undefined> {
  return AppStorage.get(StorageConstants.API_URL)
}

/**
 * 获取用户Cookie
 * @returns
 */
export async function getCookie(): Promise<string> {
  let cookie = ''
  let isCustomCookie = await AppStorage.get(StorageConstants.IS_CUSTOM_COOKIE) as boolean
  if(isCustomCookie) {
    cookie = await AppStorage.get(StorageConstants.CUSTOM_COOKIE) as string
  } else {
    cookie = await AppStorage.get(StorageConstants.COOKIE) as string
  }
  return cookie
}

interface InnerData {
  version: string
}

interface InnerVersion {
  code: number,
  data: InnerData
}
/**
 * 检查API URL连通性
 * @returns
 */
export async function checkValidUrl(): Promise<boolean> {
  try {
    AppStorage.setOrCreate(StorageConstants.IS_CHECKING_VALID_API, true)
    const response = await commonRequest<InnerVersion>({
      url: '/inner/version',
      params: { timeout: 5000, noCookie: true }
    })
    if (response.code === 200) {
      AppStorage.setOrCreate(StorageConstants.VALID_API_URL, true)
      return true
    } else {
      AppStorage.setOrCreate(StorageConstants.VALID_API_URL, false)
      return false
    }
  } catch (e) {
    AppStorage.setOrCreate(StorageConstants.VALID_API_URL, false)
    return false
  } finally {
    AppStorage.setOrCreate(StorageConstants.IS_CHECKING_VALID_API, false)
  }
}

export function getLocalSongArtistsString(localSongArtists: string): string {
  let artists: string = localSongArtists
  try {
    const artistsArr: Artist[] = JSON.parse(localSongArtists)
    artists = getArtists(artistsArr)
  } catch (e) {
    LogUtil.warn(TAG + 'getLocalSongArtistString Error')
  }
  return artists
}

export async function getLocalSongArtists(localSongArtists: string): Promise<Artist[]> {
  let artists: Artist[] = [{ id: 0, name: localSongArtists.toString() }]
  try {
    artists = JSON.parse(localSongArtists)
  } catch (e) {
    LogUtil.warn(TAG + 'getLocalSongArtists Error')
  }
  return artists
}

export async function getCacheSet() {
  try {
    const cacheSet = await AppStorage.get(StorageConstants.CACHE_SETTINGS) as CacheSet
    return cacheSet ?? CacheSet_INITIAL
  } catch (e) {
    LogUtil.error(TAG, 'getCacheSet Error: ' + e.message)
    return CacheSet_INITIAL
  }
}