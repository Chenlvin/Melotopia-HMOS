import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getPlayLists } from "../../../api/playListApi"
import Constants from "../../constants/Constants"
import { StorageConstants } from "../../constants/StorageConstants"
import { PlayList } from "../../entities/PlayList"
import { User, User_INITIAL } from "../../entities/User"
import { PlayListCard } from "../../../components/cards/PlayListCard"
import { PlayListSkeleton } from "../../../components/skeleton/Skeleton"

@Component
export struct UserPlayLists {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getPlayLists') isLogged: boolean = false
  @StorageProp(StorageConstants.USER) user: User = User_INITIAL
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: Array<PlayList> = []
  @State playListTabIndex: number = 0
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @State isLoading: boolean = false
  private refreshCooldown: number = 5000
  playListTabController: TabsController = new TabsController()

  async aboutToAppear(): Promise<void> {
    try {
      setTimeout(async () => {
        await this.getPlayLists()
      }, 100)
    } catch (e) {
      ToastUtil.showToast('获取歌单列表失败')
      LogUtil.error('Error fetching playlists: ', e.message)
    } finally {
      this.isLoading = false
    }
  }

  async getPlayLists() {
    if(this.isLogged && this.playLists.length == 0) {
      this.isLoading = true
      const playlist = await getPlayLists(0)
      this.playLists = playlist.playlist
      this.isLoading = false
    }
    else return
  }

  private async refreshContent() {
    if (this.isLogged) {
      this.isRefreshing = true
      const currentTime = new Date().getTime()
      if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
        ToastUtil.showToast('操作过于频繁，请5秒后再试')
      } else {
        try {
          const result = await getPlayLists(0)
          this.playLists = []
          this.playLists = result.playlist
          this.lastRefreshTime = currentTime
          ToastUtil.showToast('刷新成功')
        } catch (e) {
        }
      }
      this.isRefreshing = false
    }
    else return
  }

  build() {
    Column() {
      this.PlayListTabBar()
      Refresh({ refreshing: this.isRefreshing}) {
        if(this.isLoading) {
          List() {
            this.Loading()
          }
          .height('100%')
        } else {
          Tabs({ controller: this.playListTabController }) {
            TabContent() {
              this.PlayListsContent(0)
            }
            TabContent() {
              this.PlayListsContent(1)
            }
            TabContent() {
              this.PlayListsContent(2)
            }
          }

          .barHeight(0)
          .onChange((index) => {
            this.playListTabIndex = index
          })
          .scrollable(false)
        }
      }
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .onRefreshing(async () => {
        await this.refreshContent()
      })
    }
    .visibility(this.isLogged ? Visibility.Visible : Visibility.None)
  }

  @Builder PlayListTabBar() {
    Row({ space: Constants.PADDING_EDGE_TEXT }) {
      this.PlayListTabBarButtonItem('所有', 0)
      this.PlayListTabBarButtonItem('自建', 1)
      this.PlayListTabBarButtonItem('收藏', 2)
    }
    .width('100%')
    .padding({ left: 20, bottom: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder PlayListTabBarButtonItem(title: string, index: number) {
    Text(title)
      .fontSize(Constants.FONT_SIZE_COMMON)
      .fontColor(this.playListTabIndex === index ? $r('app.color.app_red') : Color.Gray)
      .fontWeight(FontWeight.Bold)
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
      .onClick(() => { this.playListTabController.changeIndex(index) })
  }

  @Builder PlayListsContent(mode: number) {
    List() {
      ForEach(mode === 0 ? this.playLists : mode === 1 ?
      this.playLists.filter((item) => item.userId === this.user.data.account.id) :
      this.playLists.filter((item) => item.userId !== this.user.data.account.id),
        (item: PlayList, index) => {
        ListItem() {
          PlayListCard({
            breakpoint: this.breakpoint,
            playList: item,
            isShowHeart: item.creator?.userId == this.user.data?.account.id ? false : true
          })
            .padding( this.breakpoint == 'md' ? 5 : { bottom: 10 } )
        }
      })
      ListItem()
      ListItem().height(px2vp(this.bottomRectHeight) + 56 + Constants.HEIGHT_MINI + Constants.PADDING_EDGE_DEFAULT*2)
    }
    .height('100%')
    .width('100%')
    .scrollBar(BarState.Off)
    .lanes(this.breakpoint === 'lg' || this.breakpoint === 'md' ? 2 : 1)
    .backToTop(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListSkeleton()
    })
  }
}