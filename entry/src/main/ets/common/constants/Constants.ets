/**
 * 常量类
 */
export default class Constants {
  /**
   * 基础服务API地址
   */
  static readonly API_URL: string = 'https://api.chenlvin.cc'
  /**
   * Mini播放器高度
   */
  static readonly HEIGHT_MINI: number = 60
  /**
   * 选择框高度
   */
  static readonly HEIGHT_SELECT: number = 35
  /**
   * 搜索框高度
   */
  static readonly HEIGHT_SEARCH: number = 40
  /**
   * 文字按钮高度
   */
  static readonly HEIGHT_TEXT_BUTTON: number = 40
  /**
   * MenuItem 默认尺寸
   */
  static readonly HEIGHT_MENU_ITEM_DEFAULT: number = 40
  /**
   * 设置项高度
   */
  static readonly HEIGHT_SETTINGS_ITEM: number = 50
  /**
   * Group设置项高度
   */
  static readonly HEIGHT_SETTINGS_GROUP_ITEM: number = 40
  /**
   * 发现页大按钮尺寸
   */
  static readonly HEIGHT_EXPLORE_LARGECARD: number = 120
  /**
   * 默认圆形icon按钮尺寸
   */
  static readonly SIZE_ICON_BUTTON_COMMON: number = 35
  /**
   * Head Icon按钮尺寸
   */
  static readonly SIZE_ICON_BUTTON_HEAD: number = 30
  /**
   * Bar Icon 按钮尺寸
   */
  static readonly SIZE_ICON_BUTTON_BAR: number = 25
  /**
   * Bar Small Icon
   */
  static readonly SIZE_ICON_BUTTON_BAR_SMALL: number = 22
  /**
   * 默认加载图标尺寸
   */
  static readonly SIZE_LOADING_PROGRESS_DEFAULT: number = 50
  /**
   * 卡片加载图标尺寸
   */
  static readonly SIZE_LOADING_PROGRESS_CARD: number = 30
  /**
   * 卡片图片 Image 尺寸
   */
  static readonly SIZE_IMG_CARD: number = 50
  /**
   * 头像尺寸
   */
  static readonly SIZE_IMG_AVATAR: number = 30
  /**
   * 卡片边框弧度
   */
  static readonly RADIUS_CARD: number = 15
  /**
   * 按钮边框弧度
   */
  static readonly RADIUS_BUTTON: number = 15
  /**
   * Image 默认弧度
   */
  static readonly RADIUS_IMG: number = 10
  /**
   * 圆形
   */
  static readonly RADIUS_FULL: number = 50
  /**
   * 标题栏字体尺寸
   */
  static readonly FONT_SIZE_TITLE: number = 20
  /**
   * 大封面字体尺寸
   */
  static readonly FONT_SIZE_COVER: number = 30
  /**
   * 普通字体尺寸
   */
  static readonly FONT_SIZE_COMMON: number = 16
  /**
   * Bar 字体尺寸
   */
  static readonly FONT_SIZE_BAR: number = 10
  /**
   * 粗体
   */
  static readonly FONT_WEIGHT_BOLD: number = 800
  /**
   * 默认边缘避让尺寸
   */
  static readonly PADDING_EDGE_DEFAULT: number = 10
  /**
   * 文字类边缘避让尺寸
   */
  static readonly PADDING_EDGE_TEXT: number = 30
  /**
   * 中等边缘避让
   */
  static readonly PADDING_MEDIUM: number = 20
  /**
   * Sheet 顶部默认避让尺寸
   */
  static readonly PADDING_SHEET_TOP_DEFAULT: number = 60
  /**
   * 组件内边缘避让
   */
  static readonly PADDING_INNER_DEFAULT: number = 5
  /**
   * 缓存图片数量
   */
  static readonly CACHE_IMAGE_MAX_COUNT: number = 50000
  /**
   * 允许缓存占用总大小
   */
  static readonly CACHE_DISK_MAX_SIZE: number = 4096 * 1024 * 1024
  /**
   * 悬浮窗歌词名字
   */
  static readonly FLOAT_LYRICS_WIN_NAME: string = 'lyricsFloatWin'
  /**
   * 悬浮窗歌词顶部避让
   */
  static readonly FLOAT_LYRICS_TOP_MARGIN: number = vp2px(42)
  /**
   * Array length 10
   */
  static readonly ARRAY_LENGTH_10: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
}