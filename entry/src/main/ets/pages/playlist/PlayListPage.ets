import { SongCard } from '../../components/cards/SongCard'
import { PlayList, PlayListItem } from '../../common/entities/playlist/PlayList'
import { DialogUtil, EmitterUtil, LogUtil, PasteboardUtil, ToastUtil } from '@pura/harmony-utils'
import { deletePlayList, getPlayListSongs, subscribePlayList } from '../../api/playListApi'
import { BottomBarComponent } from '../../components/play/BottomBarComponent'
import { formatNumber, getArtists } from '../../common/functions/common/convert'
import { cleanLastPlayInfo } from '../../common/functions/play/playListOp'
import Constants from '../../common/constants/Constants'
import { LoadingMoreButton, NoMoreButton } from '../../components/buttons/LoadMoreButtons'
import { CommentParam, CommonParam, PlayListPageParam } from '../../common/entities/local/PageParams'
import { StorageConstants } from '../../common/constants/StorageConstants'
import { PlayListSong } from '../../common/entities/playlist/PlayListSongs'
import { User, UserItem } from '../../common/entities/user/User'
import { LazyData } from '@pie/lazy-data'
import { EmitterConstants } from '../../common/constants/EmitterConstants'
import PlayQueueUtils from '../../common/utils/play/PlayQueueUtils'
import { PlayQueue } from '../../common/entities/local/PlayQueue'
import { playQueue } from '../../common/functions/play/playControl'
import { COMMENT_TYPE, PLAYMODE } from '../../common/model/Enum'
import { PlayAllButton } from '../../components/buttons/PlayAllButton'
import { BarLoading } from '../../components/cards/Loading'
import { PlayListSkeleton } from '../../components/skeleton/Skeleton'
import { ListSelectSheet } from '../../components/sheets/ListSelectSheet'
import { SimpleSong } from '../../common/entities/song/Song'

/**
 * 歌单二级页面
 */

const TAG = '[PlayListPage] '

@Component
export struct PlayListPage {
  @State param: PlayListPageParam = {
    playList: PlayListItem,
    isShowHeart: false,
    useTimestamp: true
  }
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.USER) user: User = UserItem
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.USER_PLAYLISTS) userPlayLists: PlayList[] = []
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack
  @State isSubscribed: boolean = false
  @State list: PlayListSong[] = new Array()
  @State filteredList: PlayListSong[] = new Array()
  @State listDataSource: LazyData<PlayListSong> = new LazyData()
  @State filteredDataSource: LazyData<PlayListSong> = new LazyData()
  @State hasMore: boolean = true
  @State isLoading: boolean = true
  @State translateY: number = 40
  @State searchKeyword: string = ''
  @State trackCount: number = -1
  @State showTitleBar: boolean = false
  @State isPageActive: boolean = false
  @State showSelectSheet: boolean = false
  @State simpleSongs: SimpleSong[] = []

  menus: NavigationMenuItem[] = [
    {
      value: 'Comment',
      icon: $r('app.media.ic_public_message'),
      action: () => {
        let param: CommonParam<CommentParam> = { pageName: 'CommentPage', param: {
          id: this.param.playList.id,
          name: this.param.playList.name,
          type: COMMENT_TYPE.PLAYLIST
        }, remove: true }
        EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
      }
    }
  ]
  private currentOffset: number = 0
  private useTimestamp: boolean = true

  private handleSelect = () => {
    let temp: SimpleSong[] = this.list.map((item): SimpleSong => ({
      songId: item.id,
      name: item.name,
      artists: item.ar
    }))
    this.simpleSongs = temp
    this.showSelectSheet = true
  }

  private selectSheetOptions: SheetOptions = {
    preferType: SheetType.CENTER,
    height: SheetSize.LARGE,
    dragBar: false,
    showClose: false,
    scrollSizeMode: ScrollSizeMode.FOLLOW_DETENT,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.showSelectSheet = false }
  }

  async aboutToAppear(): Promise<void> {
    this.isPageActive = true
    this.isSubscribed = this.param.playList.subscribed
    this.trackCount = this.param.playList.trackCount
    EmitterUtil.onSubscribe(EmitterConstants.EMITTER_DELETE_FROM_PLAYLIST, ((index: number) => {
      this.list.splice(index, 1)
      this.trackCount -= 1
      this.listDataSource.notifyDataReload()
      cleanLastPlayInfo()
    }))
    await this.loadSongs(200, 0)
    await this.loadSongs(this.param.playList.trackCount - 200, 150)
  }

  aboutToDisappear(): void {
    this.isPageActive = false
    EmitterUtil.unSubscribe(EmitterConstants.EMITTER_DELETE_FROM_PLAYLIST)
  }

  private async playSong(songIndex: number) {
    try {
      this.isPlayerLoading = true
      if(this.list.length === 0) return
      let queue: PlayQueue[] = this.list.map((item): PlayQueue => ({
        playmode: PLAYMODE.PLAYLIST,
        song: {
          id: item.id,
          name: item.name,
          artists: item.ar,
          album: item.al,
          duration: item.dt,
          fee: item.fee,
          alias: []
        },
        fileName: '',
        picUrl: item.al.picUrl
      }))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAdd_array(queue)
      playQueue(songIndex)
      setTimeout(() => {
        this.isPlayerLoading = false
      }, 100)
    } catch (e) {
      ToastUtil.showToast('播放失败: ' + e.message)
      LogUtil.error(TAG, 'playSong Error: ' + e.stack)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore || !this.isPageActive) return // 直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    }
    try {
      const result = await getPlayListSongs(this.param.playList.id, limit <= 1000 ? limit : 1000, offset, this.useTimestamp)
      this.list = [...this.list, ...result] // 合并歌曲列表
      this.listDataSource.setData(this.list)
      this.listDataSource.notifyDataReload()
      this.currentOffset += limit <= 1000 ? limit : 1000
      if (this.list.length >= this.param.playList.trackCount) {
        this.hasMore = false
      }
      limit -= 1000
      if(limit > 0) {
        this.loadSongs(limit, this.currentOffset)
      }
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching songs: ', e.message)
    } finally {
      this.isLoading = false
    }
  }

  private UnSubScribe() {
    DialogUtil.showPrimaryDialog({
      title: '取消收藏歌单',
      message: `《${this.param.playList.name}》`,
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          let res: boolean = await subscribePlayList(this.param.playList.id, 2)
          if(res) {
            ToastUtil.showToast('取消收藏歌单')
            this.isSubscribed = false
          }
        }
      }
    })
  }

  private handelSearch() {
    try {
      if (!this.searchKeyword) {
        this.filteredList = []
        this.filteredDataSource.setData([])
      }
      const keyword = this.searchKeyword.toLowerCase()
      this.filteredDataSource.setData(this.list.filter((item: PlayListSong) => {
        const idMatch = item.name.toString().toLowerCase().includes(keyword)
        const artistMatch = item.ar.some(artist =>
        artist.name.toLowerCase().includes(keyword))
        return idMatch || artistMatch
      }))
    } catch (e) {
      ToastUtil.showToast('搜索时出错: ' + (e as Error).message)
      LogUtil.error(TAG, 'Error while handelSearch: ' + (e as Error).message)
    }
  }

  private deleteButtonAction() {
    DialogUtil.showPrimaryDialog({
      title: '确认删除歌单',
      message:`《${this.param.playList.name}》`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          await this.handleDelete()
        }
      }
    })
  }

  private async handleDelete() {
    const result = await deletePlayList(this.param.playList.id)
    if(result) {
      ToastUtil.showToast('成功删除歌单')
      this.pageInfos.pop()
    } else {
      ToastUtil.showToast('删除歌单失败')
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          List() {
            ListItem() {
             this.PlayListInfo()
            }
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
            .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })

            ListItem() {
              Row() {
                if(this.isPlayerLoading) {
                  BarLoading()
                } else {
                  Row() {
                    Row() {
                      PlayAllButton({
                        count: this.list.length,
                        clickAction: () => {
                          if (this.isPlayerLoading) {
                            ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
                          } else {
                            this.playSong(0)
                          }
                        }
                      })
                      LoadingProgress()
                        .width(Constants.SIZE_ICON_BUTTON_BAR)
                        .visibility(this.hasMore ? Visibility.Visible : Visibility.None)
                    }
                    Image($r('app.media.ic_public_select_all'))
                      .width(Constants.SIZE_ICON_BUTTON_BAR_SMALL)
                      .fillColor($r('app.color.reverse'))
                      .onClick(this.handleSelect)
                  }
                  .width('100%')
                  .padding({ right: Constants.PADDING_MEDIUM })
                  .justifyContent(FlexAlign.SpaceBetween)
                }
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }
            if (this.isLoading) {
              ForEach(Constants.ARRAY_LENGTH_10, () => {
                PlayListSkeleton()
              })
            } else {
              ListItemGroup() {
                if(this.searchKeyword) {
                  this.ContentList(this.filteredDataSource)
                } else {
                  this.ContentList(this.listDataSource)
                }
              }

              // 添加加载更多
              if (this.hasMore) {
                ListItem() {
                  LoadingMoreButton()
                }
              }
              else if (!this.hasMore) {
                ListItem() {
                  NoMoreButton()
                }
              }
            }

            ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
          }
          .edgeEffect(EdgeEffect.None)
          .cachedCount(10)
          .height('100%')
          .layoutWeight(1)
          .width('100%')
          .scrollBar(BarState.Off)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .sticky(StickyStyle.Header | StickyStyle.Footer)
          .backToTop(true)
          .onScrollIndex((start) => {
            animateTo({ duration: 500, curve: Curve.Ease }, () => {
              if(start === 0) {
                this.showTitleBar = false
              } else {
                this.showTitleBar = true
              }
            })
          })
          .bindSheet(this.showSelectSheet, this.SelectSheet(), this.selectSheetOptions)
        }
        .height('100%')

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title(this.showTitleBar || this.searchKeyword !== '' ? this.ToolBar : '',
      {
        backgroundColor: Color.Transparent,
        barStyle: BarStyle.STACK,
        backgroundBlurStyle: this.showTitleBar ? BlurStyle.Regular : BlurStyle.NONE
      })
    .menus(this.menus)
    .backgroundColor($r('app.color.background'))
  }

  @Builder ContentList(dataSource: LazyData<PlayListSong>) {
    LazyForEach(dataSource, (item: PlayListSong) => {
      SongCard({
        playmode: PLAYMODE.PLAYLIST,
        song: {
          id: item.id,
          artists: item.ar,
          album: item.al,
          name: item.name,
          duration: item.dt,
          alias: [],
          fee: item.fee
        },
        sid: this.list.indexOf(item),
        playlist: this.param.playList,
        picUrl: item.al?.picUrl ?? $r('app.media.ic_public_music'),
        index: this.list.indexOf(item),
        listPlayAction: async () => { await this.playSong(this.list.indexOf(item)) }
      })
        .translate({ y: this.translateY })
        .animation({
          duration: 600,
          curve: Curve.LinearOutSlowIn
        })
        .onAppear(() => { this.translateY = 0 })
      }
      ,(item: PlayListSong, index) => item.name + index)
  }

  @Builder ToolBar() {
    Column() {
      Search({
        placeholder: $r('app.string.Search_content'),
        icon: '/resources/base/media/ic_public_search_filled.svg',
        value: this.searchKeyword
      })
        .backgroundBlurStyle(BlurStyle.Thin)
        .height(Constants.HEIGHT_SEARCH)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if(value == '') {
            this.filteredList = []
            this.searchKeyword = ''
          }
        })
        .onSubmit((value) => {
          this.searchKeyword = value
          this.handelSearch()
        })
    }
    .padding({ left: 20, right: 20 })
    .justifyContent(FlexAlign.Center)
    .layoutWeight(1)
  }

  @Builder PlayListInfo() {
    Column({ space: 20 }) {
      Row() {
        // CoverImage
        Stack() {
          Image('')
            .width('100%')
            .borderRadius(10)
          LoadingProgress().width(40)
          Image(`${this.param.playList.coverImgUrl}?param=256y256`)
            .width('100%')
            .borderRadius(10)
        }
        .height(100)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
        .aspectRatio(1)

        // TextInfo
        Column({ space: 5 }) {
          Text(this.param.playList.name)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .width('100%')
          Row({ space: 5 }) {
            Image(this.param.playList.creator?.avatarUrl ? this.param.playList.creator.avatarUrl + '?param=100y100' : $r('app.media.ic_user_portrait'))
              .width(14)
              .aspectRatio(1)
              .borderRadius(50)
            Text(`${this.param.playList.creator.nickname}   |   ${formatNumber(this.param.playList.playCount)} 次播放`)
              .fontSize(12)
              .width('100%')
              .textAlign(TextAlign.Start)
          }
          .width('100%')

          Text(this.param.playList?.description ? this.param.playList.description : '暂无介绍')
            .fontSize(12)
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .textAlign(TextAlign.Start)
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
            .onClick(() => {
              DialogUtil.showConfirmDialog({
                title: '歌单介绍',
                message: this.param.playList?.description ? this.param.playList.description : '暂无介绍'
              })
            })
        }
        .height(100)
        .layoutWeight(1)
        .padding({ left: Constants.PADDING_EDGE_DEFAULT })
        .justifyContent(FlexAlign.SpaceAround)
      }
      .width('100%')
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .justifyContent(FlexAlign.SpaceAround)

      Row({ space: 15 }) {
        // 分享歌单
        this.ToolButton($r('app.media.ic_public_share_filled'), '分享歌单', () => {
          PasteboardUtil.setDataText(`[${this.param.playList.name}] https://music.163.com/playlist?id=${this.param.playList.id}`)
          ToastUtil.showToast('已复制链接至剪贴板')
        })
        // 喜欢歌单
        if(this.param.isShowHeart) {
          if(this.isSubscribed) {
            this.ToolButton($r('app.media.ic_public_favor_filled'), '取消喜欢',
              () => {
                this.UnSubScribe()
              })
          } else {
            this.ToolButton($r('app.media.ic_public_favor'), '喜欢歌单',
              async () => {
                let res:boolean = await subscribePlayList(this.param.playList.id, 1)
                if(res) {
                  ToastUtil.showToast('成功收藏歌单')
                  this.isSubscribed = true
                }
              })
          }
        }
        // 删除歌单
        if(this.isLogged && this.user.data.account?.id == this.param.playList.userId &&
          this.param.playList.id != this.userPlayLists[0]?.id) {
          this.ToolButton($r('app.media.ic_public_delete_filled'), '删除歌单', () => {
            this.deleteButtonAction()
          })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
    }
    .backgroundImage(`${this.param.playList.coverImgUrl}?param=256y256`)
    .backgroundBlurStyle(BlurStyle.Regular)
    .backgroundImageSize({ width: '100%', height: '100%' })
    .padding({ top: Constants.PADDING_EDGE_TEXT + px2vp(this.topRectHeight), bottom: 20 })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .width('100%')
  }

  @Builder ToolButton(icon: ResourceStr, text: string, action: () => void) {
    Button() {
      Row({ space: 5 }) {
        Image(icon)
          .fillColor(Color.White)
          .width(Constants.FONT_SIZE_COMMON)
          .aspectRatio(1)
        Text(text)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontColor(Color.White)
      }
      .padding(Constants.PADDING_EDGE_DEFAULT)
    }
    .backgroundColor(Color.Transparent)
    .backgroundBrightness({ rate: 0.1, lightUpDegree: -0.1 })
    .backdropBlur(BlurStyle.Regular)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => { action() })
  }

  @Builder SelectSheet() {
    ListSelectSheet({ songs: this.simpleSongs, isShow: this.showSelectSheet })
  }
}