import { SongCard } from '../../components/cards/SongCard'
import { LogUtil, ToastUtil } from '@pura/harmony-utils'
import { getCloudList } from '../../api/playListApi'
import { BottomBarComponent } from '../../components/play/BottomBarComponent'
import Constants from '../../common/constants/Constants'
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from '../../components/buttons/LoadMoreButtons'
import { StorageConstants } from '../../common/constants/StorageConstants'
import { LazyData } from '@pie/lazy-data'
import { PlayQueue } from '../../common/model/PlayQueue'
import PlayQueueUtils from '../../common/utils/play/PlayQueueUtils'
import { playQueue } from '../../common/functions/play/playControl'
import { PLAYMODE } from '../../common/model/Enum'
import { PlayAllButton } from '../../components/buttons/PlayAllButton'
import { BarLoading } from '../../components/cards/Loading'
import { PlayListSong } from '../../common/entities/PlayList'

/**
 * 云盘
 */

const TAG = '[CloudPage] '

@Component
export struct CloudPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @StorageLink(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State list: PlayListSong[] = []
  @State dataSource: LazyData<PlayListSong> = new LazyData()
  @State hasMore: boolean = true
  @State hasLoaded: boolean = false
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false

  private currentOffset: number = 0

  aboutToAppear() {
    if (!this.hasLoaded) {
      this.loadSongs(200, 0)
    }
  }

  async loadSongs(limit: number, offset: number): Promise<void> {
    if (!this.hasMore) return
    if (offset == 0) {
      this.isLoading = true
    } else {
      this.isLoadingMore = true
    }

    try {
      const result = await getCloudList(offset)
      this.hasMore = result.hasMore
      let templist: PlayListSong[] = []
      for(let item of result.data) {
        templist.push(item.simpleSong)
      }
      this.list = [...this.list, ...templist]
      this.dataSource.setData(this.list)
      this.dataSource.notifyDataReload()
      this.currentOffset += limit
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasLoaded = true
    }
  }

  async playSong(songIndex: number) {
    try {
      this.isPlayerLoading = true
      let queue: PlayQueue[] = this.list.map((item): PlayQueue => ({
        playmode: 2,
        song: {
          id: item.id,
          artists: item?.ar ?? [{ id: 0, name: '未知' }],
          album: item?.al ?? { id: 0, name: '未知', artists:[], picUrl: '', size: 0 },
          name: item.name,
          duration: item.dt,
          alias: [],
          fee: item.fee
        },
        fileName: '',
        picUrl: item.al?.picUrl ?? $r('app.media.ic_public_music')
      }))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAdd_array(queue)
      playQueue(songIndex)
      setTimeout(() => {
        this.isPlayerLoading = false
      }, 100)
    } catch (e) {
    }
  }

  private handlePlayAll = () => {
    if (this.isPlayerLoading) {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    } else {
      this.playSong(0)
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if (this.isLoading) {
            Column() {
              LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
            }.height('100%').width('100%').justifyContent(FlexAlign.Center)
          } else {
            List() {
              if(this.isPlayerLoading) {
                BarLoading()
              } else {
                PlayAllButton({ count: this.list.length, clickAction: this.handlePlayAll })
              }
              LazyForEach(this.dataSource, (item: PlayListSong, index) => {
                ListItem() {
                  SongCard({
                    playmode: PLAYMODE.CLOUD,
                    song: {
                      id: item.id,
                      artists: item?.ar ?? [{ id: 0, name: '未知' }],
                      album: item?.al ?? { id: 0, name: '未知', artists:[], picUrl: '', size: 0 },
                      name: item.name,
                      duration: item.dt,
                      alias: [],
                      fee: item.fee
                    },
                    sid: this.list.indexOf(item),
                    index: index,
                    picUrl: item.al?.picUrl ?? $r('app.media.ic_public_music'),
                    listPlayAction: () => { this.playSong(index) }
                  })
                }

              })
              if (this.isLoadingMore) {
                ListItem() {
                  LoadingMoreButton()
                }
              } else if (this.hasMore) {
                ListItem() {
                  ClickToLoadButton()
                    .onClick(() => {
                      this.loadSongs(100, this.currentOffset)
                    })
                }
              } else if (!this.hasMore) {
                ListItem() {
                  NoMoreButton()
                }
              }
              ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
            }
            .height('100%')
            .layoutWeight(1)
            .width('100%')
            .scrollBar(BarState.Auto)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
            .backToTop(true)
          }
        }
        .height('100%')

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .translate({ y: -40 })
      .animation({
        duration: 600,
        curve: Curve.LinearOutSlowIn
      })
      .translate({ y: 0 })
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title($r('app.string.Cloud'))
    .backgroundColor($r('app.color.background'))
  }
}