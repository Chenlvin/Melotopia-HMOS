import { DialogUtil, ToastUtil} from "@pura/harmony-utils";
import Constants from "../constants/Constants";
import { getTopList } from "../../api/topListApi";
import { TopListItemCard } from "../../components/cards/TopListItemCard";
import { StorageConstants } from "../constants/StorageConstants";
import { getPersonalizedList } from "../../api/playListApi";
import { PersonalizedCard } from "../../components/cards/PersonalizedCard";
import { AppInfo, AppInfoClass } from "../entities/AppInfo";
import { IndexRecommend } from "./IndexRecommend";
import { PersonalizedSkeletion } from "../../components/skeleton/Skeleton";
import { ApiSetPage } from "../../pages/settings/ApiSetPage";
import RelationalStoreUtils from "../utils/data/RelationalStoreUtils";
import { FileCard } from "../../components/cards/FileCard";
import { PickerUtil } from "@pura/picker_utils";
import FileUtils from "../utils/file/FileUtils";
import { RecommendDjRadio } from "../entities/DjRadio";
import { PersonalListItem, TopListItem } from "../entities/Recommend";
import { LocalSong } from "../entities/Song";
import { AppConstants } from "../constants/AppConstants";

@Component
export struct Explore {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getContent') isLogged: boolean = false
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = true
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @StorageLink(StorageConstants.TOPLISTS) topList: Array<TopListItem> = []
  @StorageLink(StorageConstants.PERSONALIZED_LIST) personalizedList: Array<PersonalListItem> = []
  @StorageLink(StorageConstants.RECOMMENDED_DJ) recommendDjRadioList: Array<RecommendDjRadio> = []
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.SHOW_ANNOUNCEMENT) showAnnouncement: boolean = true
  @StorageProp(StorageConstants.BUNDLE_NAME) bundleName: string = ''
  @State localSongs: LocalSong[] = []
  @State isLoadingTopList: boolean = false
  @State isLoadingPersonalized: boolean = false
  @State isLoadingRecommendDjRadio: boolean = false
  @State isLoading: boolean = true
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Prop currentHour: number = 0
  @State totalOpacity: number = 0
  @State isShowApiSettings: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  aboutToAppear() {
    this.isLoading = true
    this.getContent()
    animateTo({ duration: 300, curve: Curve.Ease, delay: 100}, () => {
      this.totalOpacity = 1
    })
  }

  private async refreshLocalSongs() {
    this.localSongs = (await RelationalStoreUtils.getSongs(10))
  }

  async getContent() {
    this.getTopLists()
    this.getPersonalizedList()
    setTimeout(async () => {
      await this.refreshLocalSongs()
      this.isLoading = false
    }, 500)
  }

  private async getTopLists() {
    if(this.topList.length == 0 && this.validApiUrl) {
      this.isLoadingTopList = true
      this.topList = await getTopList()
      this.isLoadingTopList = false
    }
    else return
  }

  private async getPersonalizedList() {
    if(this.isLogged && this.personalizedList.length == 0 && this.validApiUrl) {
      this.isLoadingPersonalized = true
      this.personalizedList = await getPersonalizedList()
      setTimeout(() => { this.isLoadingPersonalized = false }, 100)
    }
  }

  private refreshContent = async () => {
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    this.refreshLocalSongs()
    // refresh online content
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else if(this.validApiUrl) {
      try {
        Promise.all([
          this.topList = await getTopList(),
          this.personalizedList = await getPersonalizedList(),
        ])
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
        ToastUtil.showToast('内容刷新失败: ' + e.message)
      }
    }
    setTimeout(() => { this.isRefreshing = false }, 100)
  }

  build() {
    Column() {
      Refresh({ refreshing: this.isRefreshing }) {
        Grid() {
          if(this.showAnnouncement) {
            if(this.appInfo.data.AnnouncementAG.isShow && this.bundleName === AppConstants.BUNDLE_NAME_AG) {
              GridItem() {
                this.Announcement(0)
              }
            } else if(this.appInfo.data.Announcement.isShow && this.bundleName !== AppConstants.BUNDLE_NAME_AG) {
              GridItem() {
                this.Announcement(1)
              }
            }
          }
          GridItem() {
            Search({
              placeholder: $r('app.string.Search_content'),
              icon: '/resources/base/media/ic_public_search_filled.svg',
            })
              .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
              .focusable(false)
              .onClick(() => {
                this.pageInfos.clear()
                this.pageInfos.pushPathByName('SearchPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true)
              })
              .layoutWeight(1)
          }
          .padding({ left: 20, right: 20 })

          GridItem() {
            Column({ space: 5 }) {
              this.Intro(this.getGreeting(this.currentHour), () => {})
              IndexRecommend({ isLogged: this.isLogged })
            }
          }

          if(this.validApiUrl) {
            GridItem() {
              Column({ space: 5 }) {
                this.Intro('推荐歌单', () => {})
                // 推荐歌单
                List() {
                  ListItem().width(5)
                  ListItem().width(5)
                  if(this.isLoadingPersonalized || this.isRefreshing) {
                    ForEach(Constants.ARRAY_LENGTH_10, (item: number) => {
                      PersonalizedSkeletion()
                    })
                  } else {
                    ForEach(this.personalizedList, (item: PersonalListItem) => {
                      PersonalizedCard({ item: item }).padding(5)
                    }, (item: PersonalListItem) => item.id.toString())
                  }
                  ListItem().width(5)
                  ListItem().width(5)
                }
                .lanes(2)
                .listDirection(Axis.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
              }
            }
            .padding({ top: 20 })

            // GridItem() {
            //   Column({ space: 5 }) {
            //     this.Intro('推荐电台', () => {})
            //     // 推荐歌单
            //     List() {
            //       ListItem().width(5)
            //       ListItem().width(5)
            //       ForEach(this.recommendDjRadioList, (item: RecommendDjRadio) => {
            //         ListItem() {
            //           DjRadioRecommendCard({ djRadio: item }).padding(10)
            //         }
            //       }, (item: PersonalListItem) => item.id.toString())
            //       ListItem().width(5)
            //       ListItem().width(5)
            //     }
            //     .listDirection(Axis.Horizontal)
            //     .scrollBar(BarState.Off)
            //     .width('100%')
            //   }
            // }
            // .padding({ top: 20 })

            GridItem() {
              Column({ space: 15 }) {
                this.Intro('排行榜', () => {
                  this.pageInfos.pushPathByName('TopListPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true)
                })
                // 排行榜
                List() {
                  ListItem().width(15)
                  ForEach(this.topList.slice(0, 10), (item: TopListItem) => {
                    ListItem() {
                      TopListItemCard({ topListItem: item, breakpoint: this.breakpoint }).padding(5)
                    }
                  })
                  ListItem() {
                    Button() {
                      Column({ space: 5 }) {
                        Stack({ alignContent: Alignment.Center }) {
                          Image($r('app.media.bg4'))
                            .width(120)
                            .aspectRatio(1)
                            .borderRadius(Constants.RADIUS_CARD)
                            .draggable(false)
                          Text('更多排行')
                            .fontSize(Constants.FONT_SIZE_COMMON + 3)
                            .fontWeight(FontWeight.Bold)
                            .fontColor(Color.White)
                        }
                        .width(120)
                        .aspectRatio(1)
                        .backgroundColor(Color.Transparent)
                      }
                    }
                    .backgroundColor(Color.Transparent)
                    .borderRadius(Constants.RADIUS_CARD)
                    .type(ButtonType.Normal)
                    .width(120)
                    .aspectRatio(1)
                    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
                    .onClick(() => { this.pageInfos.pushPathByName('TopListPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true) })
                  }.padding(5)
                  ListItem().width(15)
                }
                .listDirection(Axis.Horizontal)
                .scrollBar(BarState.Off)
                .width('100%')
                .height('auto')
              }
            }
            .padding({ top: 20 })
          }

          GridItem() {
            Column({ space: 5 }) {
              this.Intro('本地曲库', () => {
                this.pageInfos.pushPathByName('LocalSongPage', null)
              })
              // 本地曲库
              List() {
                if(this.localSongs.length === 0 && !this.isLoading) {
                  this.LocalEmpty()
                } else {
                  ListItem().width(15)
                  ListItem().width(15)
                  ForEach(this.localSongs, (item: LocalSong, index) => {
                    FileCard({ localSong: item })
                      .width(200)
                      .padding(5)
                  }, (item: LocalSong) => item.id.toString())
                  ListItem().width(15)
                  ListItem().width(15)
                }
              }
              .padding({ top: 5 })
              .lanes(2)
              .listDirection(Axis.Horizontal)
              .scrollBar(BarState.Off)
              .width('100%')
            }
          }
          .padding({ top: 20 })

          GridItem()
            .height(px2vp(this.bottomRectHeight) + 115)
        }
        .height('100%')
        .width('100%')
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Off)
        .rowsGap(15)
        .columnsTemplate('1fr')
        .layoutDirection(GridDirection.Column)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .backToTop(true)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onRefreshing(this.refreshContent)
    }
    .width('100%')
    .height('100%')
    .opacity(this.totalOpacity)
  }

  @Builder
  Loading(ht: number | string = '100%') {
    Column() {
      LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
    }
    .height(ht)
    .padding({ bottom: px2vp(this.topRectHeight) + 60 })
    .width('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  Announcement(mode: number) {
    Row() {
      Text(mode === 0 ? this.appInfo.data.AnnouncementAG.message : this.appInfo.data.Announcement.message)
        .width('100%')
        .textAlign(TextAlign.Center)
        .fontColor($r('app.color.main'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .padding({ top: 5, bottom: 5 })
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.MARQUEE })
        .onClick(() => {
          DialogUtil.showConfirmDialog({
            title: mode === 0 ? this.appInfo.data.AnnouncementAG.title : this.appInfo.data.Announcement.title,
            message: mode === 0 ? this.appInfo.data.AnnouncementAG.message : this.appInfo.data.Announcement.message
          })
        })
    }
    .backgroundColor('#fff8b8b8')
  }

  @Builder Intro(title: string, action: () => void) {
    Row({ space: 5 }) {
      Text(title)
        .textStyle(18)
      Image($r('app.media.ic_public_arrow_right'))
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor($r('app.color.reverse'))
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(action)
  }

  @Builder LocalEmpty() {
    Column({ space: 20 }) {
      Text('上传本机歌曲')
        .fontWeight(Constants.FONT_WEIGHT_BOLD)
        .fontSize(18)
        .textAlign(TextAlign.Center)
      Button('上传')
        .alignSelf(ItemAlign.Center)
        .onClick(this.handleUpload)
        .bindSheet(this.isShowApiSettings, this.ApiSettingsSheet, this.settingsSheetOptions)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
  }

  @Builder ApiSettingsSheet() {
    ApiSetPage()
  }

  private settingsSheetOptions: SheetOptions = {
    preferType: SheetType.CENTER,
    height: SheetSize.LARGE,
    dragBar: false,
    showClose: false,
    scrollSizeMode: ScrollSizeMode.FOLLOW_DETENT,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.isShowApiSettings = false }
  }

  private getGreeting(hour: number): string {
    if (hour >= 5 && hour < 7) return '清晨好'
    if (hour >= 7 && hour < 9) return '早上好'
    if (hour >= 9 && hour < 11) return '上午好'
    if (hour >= 11 && hour < 13) return '中午好'
    if (hour >= 13 && hour < 18) return '下午好'
    if (hour >= 18 && hour < 24) return '晚上好'
    if (hour >= 0 && hour < 5) return '夜已深, 注意休息'
    return '探索您喜爱的内容'
  }

  private handleUpload = async () => {
    DialogUtil.showPrimaryDialog({
      title: '上传文件',
      message: '支持上传本机音频文件至本地曲库\n' +
        '支持格式为.mp3 .flac\n\n' +
        '* 文件名格式：歌手 - 歌名.flac* \n\n' +
        '文件名格式不正确会导致无法识别\n',
      primaryButton: "取消",
      secondaryButton: {
        value: '上传',
        action: () => {
          PickerUtil.selectDocument({
            maxSelectNumber: 99,
            fileSuffixFilters: ['音频 | .mp3,.flac,.MP3,.FLAC']
          }).then((uris) => {
            FileUtils.saveFilesToDirectory(uris).then(async (result) => {
              if(result) {
                ToastUtil.showToast(`上传 ${result} 个文件`)
                this.refreshLocalSongs()
              }
            })
          })
        }
      }
    })
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .fontWeight(FontWeight.Bold)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 20 })
}