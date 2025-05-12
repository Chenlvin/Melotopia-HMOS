import { LogUtil } from "@pura/harmony-utils"
import { searchPlayLists } from "../../api/playListApi"
import Constants from "../../common/constants/Constants"
import { PlayList } from "../../common/entities/PlayList"
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from "../buttons/LoadMoreButtons"
import { PlayListCard } from "../cards/PlayListCard"

const TAG = "[SearchPlayListsList] "
@Component
export struct SearchPlayListsList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State playLists: Array<PlayList> = []
  @Link @Watch('handleSearch') searchKeyword: string
  @State playListOffset: number = 0
  @State hasMorePlayLists: boolean = true
  @State hasPlayListLoaded: boolean = false
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.loadPlayLists(0)
    }
  }

  async handleSearch() {
    this.playLists = []
    this.playListOffset = 0
    await this.loadPlayLists(0)
  }

  build() {
    if(this.isLoading == true) {
      Column() {
        LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
      }
      .padding({ bottom: px2vp(this.topRectHeight) })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: 5 }) {
        ForEach(this.playLists, (item: PlayList, index) => {
          ListItem() {
            PlayListCard({ playList: item })
          }
          .translate({ y: -40 })
          .animation({
            duration: 600,
            curve: Curve.LinearOutSlowIn
          })
          .translate({ y: 0 })
        })
        if (this.isLoadingMore) {
          ListItem() {
            LoadingMoreButton()
          }
        } else if (this.hasMorePlayLists && this.searchKeyword) {
          ListItem() {
            ClickToLoadButton()
              .onClick(() => {
                this.loadPlayLists(this.playListOffset)
              })
          }
        } else if (!this.hasMorePlayLists) {
          ListItem() {
            NoMoreButton()
          }
        }
        ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
      }
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }

  async loadPlayLists(offset: number): Promise<void> {
    if(!this.hasMorePlayLists) return
    if(offset == 0) { this.isLoading = true }
    else { this.isLoadingMore = true }
    try {
      const result = await searchPlayLists(this.searchKeyword, offset)
      this.playLists = [...this.playLists, ...result.playlist]
      this.playListOffset += 15
      this.hasMorePlayLists = result.more
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching playLists: ', JSON.stringify(e));
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasPlayListLoaded = true
    }
  }
}