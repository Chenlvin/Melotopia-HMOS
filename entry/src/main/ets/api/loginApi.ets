import { LogUtil } from "@pura/harmony-utils"
import { User, User_INITIAL } from "../common/entities/User"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import { StorageConstants } from "../common/constants/StorageConstants"
import commonRequest from "../common/utils/request/RequestUtil"

/**
 * 获取登录状态
 * @param cookie
 */
export const getLoginStatus = async (cookie: string): Promise<boolean> => {
  try {
    const response = await commonRequest<User>({
      url: '/login/status',
      params: { timestamp: new Date().getTime() }
    })
    if (response.data.account.id && response.data.profile.nickname) {
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER, response)
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE, cookie)
      AppStorage.setOrCreate(StorageConstants.VIP_TYPE, response.data.account.vipType)
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, true)
      AppStorage.setOrCreate(StorageConstants.USER, response)
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, true)
      return true
    } else {
      Promise.all([
        PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER, User_INITIAL),
        PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE, ''),
        PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, []),
        PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, []),
        PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, [])
      ])
      AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
      AppStorage.setOrCreate(StorageConstants.COOKIE, '')
      AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
      AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
      return false
    }
  } catch (error) {
    LogUtil.error('获取登录状态失败: ', error.message)
    return false
  }
}

interface LogOutResponse {
  code: number
}

/**
 * 退出登录
 */
export const logOut = async (): Promise<boolean> => {
  const response = await commonRequest<LogOutResponse>({
    url: '/logout',
    params: { timestamp: new Date().getTime() }
  })
  if(response.code === 200) {
    Promise.all([
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER, User_INITIAL),
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.COOKIE, ''),
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, []),
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, []),
      PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, [])
    ])
    AppStorage.setOrCreate(StorageConstants.VALID_COOKIE, false)
    AppStorage.setOrCreate(StorageConstants.COOKIE, '')
    AppStorage.setOrCreate(StorageConstants.IS_LOGGED, false)
    AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, [])
    return true
  }
  return false
}