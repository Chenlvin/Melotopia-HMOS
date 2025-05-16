import { LazyData } from "@pie/lazy-data"
import { EmitterUtil, ToastUtil } from "@pura/harmony-utils"
import { getDjPrograms } from "../../api/djApi"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { DjRadio_INITIAL, DjRadioProgram } from "../../common/entities/DjRadio"
import { CommentParam, CommonParam, DjRadioParam } from "../../common/model/PageParams"
import { PlayQueue } from "../../common/model/PlayQueue"
import { djRadioToQueue } from "../../common/functions/play/djRadioOp"
import { playQueue } from "../../common/functions/play/playControl"
import { COMMENT_TYPE, PLAYMODE } from "../../common/model/Enum"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from "../../components/buttons/LoadMoreButtons"
import { PlayAllButton } from "../../components/buttons/PlayAllButton"
import { BarLoading } from "../../components/cards/Loading"
import { SongCard } from "../../components/cards/SongCard"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"

@Component
export struct DjRadioPage {
  param: DjRadioParam = { djRadio: DjRadio_INITIAL }
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @State programs: DjRadioProgram[] = []
  @State dataSource: LazyData<DjRadioProgram> = new LazyData()
  @State songsOffset: number = 0
  @State translateY: number = 40
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false
  @State hasMore: boolean = false

  menus: NavigationMenuItem[] = [
    {
      value: 'Comment',
      icon: $r('app.media.ic_public_message'),
      action: () => {
        let param: CommonParam<CommentParam> = { pageName: 'CommentPage', param: {
          id: this.param.djRadio.id,
          name: this.param.djRadio.name,
          type: COMMENT_TYPE.RADIO
        }, remove: true }
        EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
      }
    }
  ]

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    await this.loadSongs(0)
    this.isLoading = false
  }

  async loadSongs(offset: number) {
    let result = await getDjPrograms(this.param.djRadio.id, 50, offset)
    this.songsOffset += 50
    this.hasMore = result.more
    this.programs = [...this.programs, ...result.programs]
    this.dataSource.setData(this.programs)
    this.dataSource.notifyDataReload()
  }

  async playSong(songIndex: number) {
    try {
      if(this.programs.length === 0) return
      let queue: PlayQueue[] = this.programs.map((item): PlayQueue => ({
        playmode: PLAYMODE.DJRADIO,
        song: item.mainSong,
        fileName: '',
        picUrl: item.coverUrl
      }))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAdd_array(queue)
      playQueue(songIndex)
    } catch (e) {
      ToastUtil.showToast('播放失败: ' + e.message)
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress()
              .width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        }
        else {
          List() {
            ListItem()
              .height(px2vp(this.topRectHeight) + 35)
            ListItem() {
              if(this.isPlayerLoading) {
                BarLoading()
              } else {
                PlayAllButton({
                  count: this.param.djRadio.programCount > 500 ? 500 : this.param.djRadio.programCount,
                  clickAction: () => {
                    if (this.isPlayerLoading) {
                      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
                    } else {
                      djRadioToQueue(this.param.djRadio.id, this.param.djRadio.programCount > 500 ? 500 : this.param.djRadio.programCount)
                    }
                  }
                })
              }
            }
            LazyForEach(this.dataSource, (item: DjRadioProgram, index) => {
              SongCard({
                song: item.mainSong,
                picUrl: item.coverUrl,
                playmode: PLAYMODE.DJRADIO,
                sid: index,
                index: index,
                listPlayAction: async () => { this.playSong(index) }
              })
                .translate({ y: this.translateY })
                .animation({
                  duration: 600,
                  curve: Curve.LinearOutSlowIn
                })
                .onAppear(() => { this.translateY = 0 })
            })

            if(this.hasMore) {
              if(this.isLoadingMore) {
                LoadingMoreButton()
              } else {
                ClickToLoadButton()
                  .padding({ left: Constants.PADDING_MEDIUM, right: Constants.PADDING_MEDIUM })
                  .onClick(async() => {
                    this.isLoadingMore = true
                    await this.loadSongs(this.songsOffset)
                    this.isLoadingMore = false
                  })
              }
            } else {
              NoMoreButton()
            }

            ListItem()
              .height(Constants.HEIGHT_MINI + px2vp(this.bottomRectHeight))
          }
          .width('100%')
          .height('100%')
          .backToTop(true)
          .scrollBar(this.programs.length < 20 ? BarState.Off : BarState.On)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
    }
    .title(this.param.djRadio.name, { barStyle: BarStyle.STACK, backgroundColor: Color.Transparent, backgroundBlurStyle: BlurStyle.Regular })
    .backgroundColor($r('app.color.background'))
    .menus(this.menus)
  }
}