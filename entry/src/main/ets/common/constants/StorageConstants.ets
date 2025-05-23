/**
 * 存储常量
 */
export class StorageConstants {
  /**
   * Context
   * @description AppStorage
   */
  static readonly CONTEXT: string = 'Context'
  /**
   * App 信息
   * @description AppStorage
   */
  static readonly APP_INFO: string = 'AppInfo'
  /**
   * 初始化应用
   * @description AppStorage
   */
  static readonly APP_LOADING: string = 'isAppLoading'
  /**
   * Current Breakpoint
   * @description AppStorage
   */
  static readonly BREAKPOINT: string = 'currentBreakpoint'
  /**
   * Current Width Breakpoint
   * @description AppStorage
   */
  static readonly BREAKPOINT_WIDTH: string = 'currentWidthBreakpoint'
  /**
   * Current Height Breakpoint
   * @description AppStorage
   */
  static readonly BREAKPOINT_HEIGHT: string = 'currentHeightBreakpoint'
  /**
   * Bottom Rect Height
   * @description AppStorage
   */
  static readonly BOTTOM_RECT_HEIGHT: string = 'bottomRectHeight'
  /**
   * Current TopRectHeight
   * @description AppStorage
   */
  static readonly TOP_RECT_HEIGHT: string = 'topRectHeight'
  /**
   * API URL 是否有效
   * @description AppStorage
   */
  static readonly VALID_API_URL: string = 'isValidApiUrl'
  /**
   * 设备类型
   * @description AppStorage
   */
  static readonly DEVICE_TYPE: string = 'deviceType'
  /**
   * Vip类型
   * @description AppStorage
   */
  static readonly VIP_TYPE: string = 'vipType'
  /**
   * Cookie 有效性
   * @description AppStorage
   */
  static readonly VALID_COOKIE: string = 'isValidCookie'
  /**
   * Is Logged
   * @description AppStorage
   */
  static readonly IS_LOGGED: string = 'isLogged'
  /**
   * 是否为本地文件 - boolean
   * @description AppStorage
   */
  static readonly PLAY_IS_LOCALFILE: string = 'play-is-localfile'
  /**
   * 倒计时时间 - number
   * @description AppStorage
   */
  static readonly PLAY_COUNTDOWN: string = 'play-countdown'
  /**
   * 倒计时是否工作 - boolean
   * @description AppStorage
   */
  static readonly PLAY_COUNTDOWN_WORKING: string = 'play-countdown-working'
  /**
   * timer(IntervalID) - number
   * @description AppStorage
   */
  static readonly PLAY_COUNTDOWN_TIMER: string = 'play-countdown-timer'
  /**
   * 用户喜欢的音乐歌单
   * @description AppStorage
   */
  static readonly PLAYLIST_LIKED: string = 'playlist-liked'
  /**
   * 播放器是否正在播放
   * @description AppStorage
   */
  static readonly IS_PLAYING: string = 'player-isplaying'
  /**
   * 播放器是否暂停
   * @description AppStorage
   */
  static readonly IS_PAUSED: string = 'player-ispaused'
  /**
   * 播放模式
   * @description AppStorage
   */
  static readonly PLAY_MODE: string = 'player-mode'
  /**
   * 歌曲文件名
   * @description AppStorage
   */
  static readonly PLAY_FILE_NAME: string = 'player-fileName'
  /**
   * 歌曲SongClass
   * @description AppStorage
   */
  static readonly PLAY_SONG: string = 'player-song'
  /**
   * 歌曲歌手
   * @description AppStorage
   */
  static readonly PLAY_ARTISTS: string = 'player-artists'
  /**
   * 当前播放的时间
   * @description AppStorage
   */
  static readonly PLAY_TIME: string = 'player-time'
  /**
   * 当前歌词
   * @default AppStorage
   */
  static readonly CURRENT_LYRIC: string = 'player-currentLyric'
  /**
   * 当前歌词序号
   * @default AppStorage
   */
  static readonly CURRENT_LYRIC_INDEX: string = 'player-currentLyricIndex'
  /**
   * 歌曲封面Url
   * @description AppStorage
   */
  static readonly PIC_URL: string = 'player-picurl'
  /**
   * 是否喜欢当前歌曲
   * @description AppStorage
   */
  static readonly ISLIKED: string = 'player-isLiked'
  /**
   * 用户喜欢的音乐列表 string[]
   * @description AppStorage
   */
  static readonly USER_LIKELIST: string = 'user-likelist'
  /**
   * 是否有正在进行的播放任务
   * (如 添加整个歌单至播放列表)
   * @description AppStorage
   */
  static readonly IS_PLAYER_LOADING: string = 'isPlayerLoading'
  /**
   * 是否正在迁移数据
   * @description AppStorage
   */
  static readonly IS_MIGRATING_LOCALFILES: string = 'isMigratingLocalFiles'
  /**
   * 上一次播放的歌单数据
   * @description AppStorage
   */
  static readonly LAST_PLAYED_LIST: string = 'lastPlayedList'
  /**
   * 上一次播放的播客数据
   * @description AppStorage
   */
  static readonly LAST_PLAYED_DJRADIO: string = 'lastPlayedDjRadio'
  /**
   * 是否开启私人FM模式
   * @description AppStorage
   */
  static readonly IS_PERSONAL_FM: string = 'isPersonalFm'
  /**
   * 私人FM模式number
   * @description AppStorage
   */
  static readonly PERSONAL_FM_MODE: string = 'personalFmMode'
  /**
   * 全屏播放界面开启
   * @description AppStorage
   */
  static readonly IS_PLAYER_SHOW: string = 'isPlayerShow'
  /**
   * 是否正在下载
   * @description AppStorage
   */
  static readonly IS_DOWNLOADING: string = 'isDownloading'
  /**
   * 是否暂停下载
   * @description AppStorage
   */
  static readonly IS_DOWNLOAD_PAUSED: string = 'isDownloadPaused'
  /**
   * 下载进度
   * @description AppStorage
   */
  static readonly DOWNLOADING_PROGRESS: string = 'downloadingProgress'
  /**
   * 是否处于前台
   * @description AppStorage
   */
  static readonly IS_IN_FOREGROUND: string = 'isInForeground'
  /**
   * 正在清理缓存歌曲
   * @description AppStorage
   */
  static readonly IS_CLEAN_CACHED_SONGS: string = 'isCleanCachedSongs'
  /**
   * 正在检查云配置连通性
   * @description AppStorage
   */
  static readonly IS_CHECKING_VALID_API: string = 'isCheckingValidApi'
  /**
   * BundleName
   * @description AppStorage
   */
  static readonly BUNDLE_NAME: string = 'bundleName'
  /**
   * Window Status Type
   * @description AppStorage
   */
  static readonly WINDOW_STATUS_TYPE: string = 'windowStatusType'



  /**
   * 用户信息
   * @description Preference
   */
  static readonly USER_PREF: string = 'UserPreference'
  /**
   * 设置信息
   * @description Preference
   */
  static readonly SET_PERF: string = 'Settings'
  /**
   * 播放信息
   * @description Preference
   */
  static readonly QUEUE_PREF: string = 'Play'



  /**
   * Cookie
   * @description AppStorage & Preference
   */
  static readonly COOKIE: string = 'cookie'
  /**
   * 用户信息
   * @description AppStorage & Preference
   */
  static readonly USER: string = 'user'
  /**
   * 用户歌单
   * @description AppStorage & Preference
   */
  static readonly USER_PLAYLISTS: string = 'userPlayLists'
  /**
   * 用户歌单
   * @description AppStorage & Preference
   */
  static readonly USER_DJRADIO_LIST: string = 'userDjRadioList'
  /**
   * 用户收藏专辑
   * @description AppStorage & Preference
   */
  static readonly USER_SUB_ALBUM: string = 'userSubAlbum'
  /**
   * 用户歌单
   * @description AppStorage & Preference
   */
  static readonly TOPLISTS: string = 'topLists'
  /**
   * 循环模式
   * @description AppStorage & Preference
   */
  static readonly CYCLE_MODE: string = 'cycleMode'
  /**
   * 播放品质
   * @description AppStorage & Preference
   */
  static readonly PLAY_QUALITY: string = 'playQuality'
  /**
   * 是否启用公共Cookie
   * @description AppStorage & Preference
   */
  static readonly USE_PUBLIC_COOKIE: string = 'usePublicCookie'
  /**
   * 历史搜索记录
   * @description AppStorage & Preference
   */
  static readonly SEARCH_HISTORY: string = 'searchHistory'
  /**
   * 和其他应用同时播放
   * @description AppStorage & Preference
   */
  static readonly MIX_WITH_OTHERS: string = 'mixWithOthers'
  /**
   * 自定义API Url & Cookie
   * @description AppStorage & Preference
   */
  static readonly API_URL: string = 'apiUrl'
  static readonly CUSTOM_COOKIE: string = 'customCookie'
  static readonly IS_CUSTOM_COOKIE: string = 'isCustomCookie'
  /**
   * 个性化推荐歌单
   * @description AppStorage & Preference
   */
  static readonly PERSONALIZED_LIST: string = 'personalizedList'
  /**
   * 推荐电台
   * @description AppStorage & Preference
   */
  static readonly RECOMMENDED_DJ: string = 'recommendedDj'
  /**
   * 歌词样式
   * @description AppStorage & Preference
   */
  static readonly LYRIC_STYLE: string = 'lyricStyles'
  /**
   * 缓存设置
   * @description AppStorage & Preference
   */
  static readonly CACHE_SETTINGS: string = 'cacheSet'
  /**
   * 浮动歌词设置
   * @description AppStorage & Preference
   */
  static readonly FLOAT_LYRIC_STYLE: string = 'floatLyricStyle'
  /**
   * Api/Webdav设置
   * @description AppStorage & Preference
   */
  static readonly API_SETTINGS: string = 'apiSettings'
  /**
   * Download Queue
   * @description AppStorage & Preference
   */
  static readonly DOWNLOAD_QUEUE: string = 'downloadQueue'
  /**
   * MiniPlayerBlur
   * @description AppStorage & Preference
   */
  static readonly MINI_BAR_BLUR: string = 'miniBarBlur'
  /**
   * New Lyric Effect
   * @description AppStorage & Preference
   */
  static readonly NEW_LYRIC_EFFECT: string = 'newLyricEffect'
  /**
   * ShowAnnouncement
   * @description AppStorage & Preference
   */
  static readonly SHOW_ANNOUNCEMENT: string = 'showAnnouncement'
  /**
   * RealIP
   * @description AppStorage & Preference
   */
  static readonly REAL_IP: string = 'realIp'
}