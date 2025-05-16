import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../../constants/StorageConstants"
import { CacheSet, CacheSet_INITIAL,
  FloatLyric,
  FloatLyric_INITIAL, LyricStyle, LyricStyle_INITIAL,
  RealIP,
  RealIP_INITIAL } from "../../model/Settings"
import PreferencesUtils from "../../utils/data/PreferencesUtils"
import { preferences } from "@kit.ArkData"
import { Api, Api_INITIAL } from "../../model/Api"

/**
 * 设置项
 */
const TAG = '[settings] '

/**
 * 初始化应用设置
 */
export async function initSettings() {
  const SetPerf = StorageConstants.SET_PERF
  // 并行处理无依赖的配置项
  await Promise.all([
    // API
    handleSetting<string>(StorageConstants.API_URL, 'http://:80'),
    // Play Quality
    handleSetting<number>(StorageConstants.PLAY_QUALITY, 0),
    // Lyric
    handleSetting<LyricStyle>(StorageConstants.LYRIC_STYLE, LyricStyle_INITIAL),
    // CacheSettings
    handleSetting<CacheSet>(StorageConstants.CACHE_SETTINGS, CacheSet_INITIAL),
    // Real Ip
    handleSetting<RealIP>(StorageConstants.REAL_IP, RealIP_INITIAL),
    // mixWithOthers
    handleSetting<boolean>(StorageConstants.MIX_WITH_OTHERS, false),
    // MiniBarBlur
    handleSetting<boolean>(StorageConstants.MINI_BAR_BLUR, true),
    // showAnnouncement
    handleSetting<boolean>(StorageConstants.SHOW_ANNOUNCEMENT, true),
    // NewLyricEffect
    handleSetting<boolean>(StorageConstants.NEW_LYRIC_EFFECT, false),
    // floatLyricStyle
    handleSetting<FloatLyric>(StorageConstants.FLOAT_LYRIC_STYLE, FloatLyric_INITIAL),
    // apiSettings
    handleSetting<Api>(StorageConstants.API_SETTINGS, Api_INITIAL)
  ])

  // 处理关联配置项（API URL）
  const results = await Promise.all([
    PreferencesUtils.hasPreferenceValue(SetPerf, StorageConstants.IS_CUSTOM_COOKIE),
  ])
  const isCustomCookieExist = results[0]

  // 手动Cookie设置
  if (!isCustomCookieExist) {
    await Promise.all([
      PreferencesUtils.putPreferenceValue(SetPerf, StorageConstants.IS_CUSTOM_COOKIE, false),
      PreferencesUtils.putPreferenceValue(SetPerf, StorageConstants.CUSTOM_COOKIE, 'MUSIC_U=')
    ])
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, false)
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE, 'MUSIC_U=')
  } else {
    const customResults = await Promise.all([
      PreferencesUtils.getPreferenceValue(SetPerf, StorageConstants.IS_CUSTOM_COOKIE, false),
      PreferencesUtils.getPreferenceValue(SetPerf, StorageConstants.CUSTOM_COOKIE, 'MUSIC_U=')
    ])
    const isCustom = customResults[0]
    const cookie = customResults[1]
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, isCustom)
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE, cookie)
  }

  // 私人FM
  AppStorage.setOrCreate(StorageConstants.IS_PERSONAL_FM, false)
  AppStorage.setOrCreate(StorageConstants.PERSONAL_FM_MODE, 0)
}

export async function changeSettings<T extends preferences.ValueType>(name: string, value: T) {
  try {
    await PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, name, value)
    AppStorage.setOrCreate(name, value)
  } catch (e) {
    ToastUtil.showToast('更改设置失败')
    LogUtil.error(TAG, 'Error while changing settings: ' + e.message)
  }
}

async function handleSetting<T extends preferences.ValueType>(
  key: string,
  defaultValue: T,
  storageArea: string = StorageConstants.SET_PERF
): Promise<void> {
  const exists = await PreferencesUtils.hasPreferenceValue(storageArea, key)
  let value: T = exists
    ? (await PreferencesUtils.getPreferenceValue(storageArea, key, defaultValue))
    : defaultValue
  if (!exists) {
    await PreferencesUtils.putPreferenceValue(storageArea, key, defaultValue)
  }
  AppStorage.setOrCreate(key, value)
}