import { SongCard } from '../../components/cards/SongCard'
import { LogUtil } from '@pura/harmony-utils'
import { DailySongRes } from '../../api/playListApi'
import { BottomBarComponent } from '../../components/play/BottomBarComponent'
import { getDailySongs } from '../../api/songApi'
import Constants from '../../common/constants/Constants'
import { StorageConstants } from '../../common/constants/StorageConstants'
import { PlayQueue } from '../../common/model/PlayQueue'
import PlayQueueUtils from '../../common/utils/play/PlayQueueUtils'
import { playQueue } from '../../common/functions/play/playControl'
import { PLAYMODE } from '../../common/model/Enum'
import { PlayAllButton } from '../../components/buttons/PlayAllButton'
import { PlayListSkeleton } from '../../components/skeleton/Skeleton'

/**
 * 每日推荐歌单页面
 */

const TAG = 'DailyListPage'

@Component
export struct DailyListPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State list: DailySongRes[] = new Array()
  @State isLoading: boolean = true
  @State pageOpacity: number = 1
  @State totayDate: string = ''

  async aboutToAppear() {
    let date = new Date()
    this.totayDate = `${date.toDateString()}`
    setTimeout(async () => {
      await this.loadSongs()
    }, 500)
  }

  async loadSongs(): Promise<void> {
    this.isLoading = true
    try {
      let result: DailySongRes[] = await getDailySongs()
      if(result.length < 3) { result = await getDailySongs(false) }
      this.list = result
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching songs: ', e)
    } finally {
      this.isLoading = false
    }
  }

  async playSong(songIndex: number) {
    try {
      let queue: PlayQueue[] = this.list.map((item): PlayQueue => ({
        playmode: 2,
        song: item.song,
        fileName: '',
        picUrl: item.picUrl
      }))
      await PlayQueueUtils.cleanQueue()
      await PlayQueueUtils.queueAdd_array(queue)
      playQueue(songIndex)
    } catch (e) {
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        List() {
          ListItem() {
            this.Info()
          }
          if(this.isLoading) {
            ForEach(Constants.ARRAY_LENGTH_10, (index: number) => {
              PlayListSkeleton()
            })
          } else {
            ListItem() {
              PlayAllButton({
                count: this.list.length,
                clickAction: () => {
                  this.playSong(0)
                }
              })
            }
            .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })

            ForEach(this.list, (item: DailySongRes, index) => {
              ListItem() {
                SongCard({
                  playmode: PLAYMODE.DAILY,
                  song: item.song,
                  sid: index,
                  index: index,
                  reason: item.reason,
                  picUrl: item.picUrl ?? '',
                  listPlayAction: () => { this.playSong(index) }
                })
              }
              .translate({ y: -40 })
              .animation({
                duration: 600,
                curve: Curve.LinearOutSlowIn
              })
              .translate({ y: 0 })
              .key(item.song.id.toString())
            })
          }
          ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
        }
        .height('100%')
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        .backToTop(true)

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .opacity(this.pageOpacity)
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .title('每日推荐')
    .backgroundColor($r('app.color.background'))
  }

  @Builder
  Info() {
    Column({ space: 5 }) {
      Text(this.totayDate)
        .fontWeight(FontWeight.Bold)
        .fontSize(18)
        .width('100%')
      Text('根据你的音乐口味生成，每天6:00更新')
        .fontSize(12)
        .width('100%')
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20 })
  }
}