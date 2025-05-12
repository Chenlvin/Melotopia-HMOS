import { AppUtil, LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getAppInfo } from "../../../api/chenlvinApi"
import { Song, Song_INITIAL } from "../../entities/Song"
import PlayQueueUtils from "../../utils/play/PlayQueueUtils"
import PreferencesUtils from "../../utils/data/PreferencesUtils"
import { StorageConstants } from "../../constants/StorageConstants"
import { notificationManager } from "@kit.NotificationKit"
import { resourceManager } from "@kit.LocalizationKit"
import { initSettings } from "./settings"
import { getLoginStatus } from "../../../api/loginApi"
import { PlayingPlayList, PlayList } from "../../entities/PlayList"
import { getLikeList } from "../../../api/songApi"
import RelationalStoreUtils from "../../utils/data/RelationalStoreUtils"
import AudioCacheUtils from "../../utils/play/AudioCacheUtils"
import { Album } from "../../entities/Album"
import { checkValidUrl } from "../common/get"
import DownloadUtils from "../../utils/file/DownloadUtils"
import { DjRadio } from "../../entities/DjRadio"
import { PersonalListItem, TopListItem } from "../../entities/Recommend"

/**
 * App初始化
 */
const TAG = 'AppInit'

export async function appInit() {
  AppStorage.setOrCreate(StorageConstants.APP_LOADING, true)
  await initSettings()
  initApp()
  await initLists()
  loadSavedSong()
  initPermission()
  initLocalData()
  getAppInfo()
  let validApi = await checkValidUrl()
  if(validApi) {
    await initUserInfo()
  }
  AppStorage.setOrCreate(StorageConstants.APP_LOADING, false)
}

function initApp() {
  AudioCacheUtils.init()
}

async function initPermission() {
  notificationManager.requestEnableNotification(AppUtil.getContext()).then(() => {
  })
}

export async function initUserInfo() {
  const cookie = await PreferencesUtils.getPreferenceValue<string>(StorageConstants.USER_PREF, StorageConstants.COOKIE, '')
  AppStorage.setOrCreate(StorageConstants.COOKIE, cookie)
  let isLogged = await getLoginStatus(cookie)
  if(!isLogged && cookie) {
    ToastUtil.showToast('登录状态失效')
  } else {
    getLikeList()
  }
}

async function initLocalData() {
  RelationalStoreUtils.init()

  let userLikeList: string[] = []
  AppStorage.setOrCreate(StorageConstants.USER_LIKELIST, userLikeList)
  const playInfo: PlayingPlayList = {
    id: -1,
    count: -1
  }
  AppStorage.setOrCreate(StorageConstants.LAST_PLAYED_LIST, playInfo)

  const results = await Promise.all([
    getDeviceTypeInfo(),
    PreferencesUtils.getPreferenceValue<PlayList[]>(StorageConstants.USER_PREF, StorageConstants.USER_PLAYLISTS, []),
    PreferencesUtils.getPreferenceValue<TopListItem[]>(StorageConstants.USER_PREF, StorageConstants.TOPLISTS, []),
    PreferencesUtils.getPreferenceValue<PersonalListItem[]>(StorageConstants.USER_PREF, StorageConstants.PERSONALIZED_LIST, []),
    PreferencesUtils.getPreferenceValue<string[]>(StorageConstants.USER_PREF, StorageConstants.SEARCH_HISTORY, []),
    PreferencesUtils.getPreferenceValue<Album[]>(StorageConstants.USER_PREF, StorageConstants.USER_SUB_ALBUM, []),
    PreferencesUtils.getPreferenceValue<DjRadio[]>(StorageConstants.USER_PREF, StorageConstants.USER_DJRADIO_LIST, [])
  ])

  AppStorage.setOrCreate(StorageConstants.DEVICE_TYPE, results[0])
  AppStorage.setOrCreate(StorageConstants.USER_PLAYLISTS, results[1])
  AppStorage.setOrCreate(StorageConstants.TOPLISTS, results[2])
  AppStorage.setOrCreate(StorageConstants.PERSONALIZED_LIST, results[3])
  AppStorage.setOrCreate(StorageConstants.SEARCH_HISTORY, results[4])
  AppStorage.setOrCreate(StorageConstants.USER_SUB_ALBUM, results[5])
  AppStorage.setOrCreate(StorageConstants.USER_DJRADIO_LIST, results[6])
}

/**
 * 初始化列表
 */
async function initLists() {
  await PlayQueueUtils.init()
  DownloadUtils.init()
}

/**
 * 加载上一次的播放内容
 */
async function loadSavedSong() {
  let has = await PreferencesUtils.getPreferenceValue<boolean>('Play','hasCurrentSong', false)
  let song: Song = {
    id: 0,
    name: "暂无播放",
    artists: [],
    album: {
      id: 0,
      name: '',
      picUrl: '',
      artists: [],
      size: 0
    },
    duration: 0,
    alias: [],
    fee: 0
  }
  let artists = '选择一首歌曲播放吧'
  let picUrl: string = ''
  let playMode: number = 0

  if(has) {
    song = await PreferencesUtils.getPreferenceValue<Song>('Play', 'CurrentSong', Song_INITIAL)
    playMode = await PreferencesUtils.getPreferenceValue<number>('Play', 'PlayMode', 1)
    artists = await PreferencesUtils.getPreferenceValue<string>('Play', 'CurrentArtists', '')
    picUrl = await PreferencesUtils.getPreferenceValue<string>('Play', 'CurrentImage', '')
    let currentIndex = await PreferencesUtils.getPreferenceValue<number>('Play', 'CurrentQueueIndex', 0)
    await PlayQueueUtils.setIndex(currentIndex)
  }
  AppStorage.setOrCreate(StorageConstants.PLAY_MODE, playMode)
  AppStorage.setOrCreate(StorageConstants.PLAY_SONG, song)
  AppStorage.setOrCreate(StorageConstants.PLAY_ARTISTS, artists)
  AppStorage.setOrCreate(StorageConstants.PIC_URL, picUrl)
}

/**
 * 获取当前设备类型
 */
async function getDeviceTypeInfo(): Promise<resourceManager.DeviceType> {
  let deviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  try {
    deviceType = getContext().resourceManager.getDeviceCapabilitySync().deviceType
  } catch (e) {
    LogUtil.error(TAG, 'Failed to get device type: ' + e.message)
  }
  return deviceType
}
