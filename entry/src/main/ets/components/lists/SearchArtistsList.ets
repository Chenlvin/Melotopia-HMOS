import { LogUtil } from "@pura/harmony-utils"
import { searchArtists } from "../../api/artistApi"
import Constants from "../../common/constants/Constants"
import { ArtistItem } from "../../common/entities/Artists"
import { ArtistCard } from "../cards/ArtistCard"

/**
 * 艺术家搜索结果列表
 */
const TAG = "[SearchArtistsList] "

@Component
export struct SearchArtistsList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State artists: Array<ArtistItem> = []
  @Link @Watch('handleSearch') searchKeyword: string
  @State hasArtistLoaded: boolean = false
  @State isLoading: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.loadArtists()
    }
  }

  async handleSearch() {
    this.artists = []
    await this.loadArtists()
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
      List({ space: Constants.PADDING_EDGE_DEFAULT }) {
        ForEach(this.artists, (item: ArtistItem) => {
          ListItem() {
            ArtistCard({ artistItem: item })
          }
          .translate({ y: -40 })
          .animation({
            duration: 600,
            curve: Curve.LinearOutSlowIn
          })
          .translate({ y: 0 })
        })
        ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
      }
      .translate({ y: -40 })
      .animation({
        duration: 600,
        curve: Curve.LinearOutSlowIn
      })
      .translate({ y: 0 })
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }

  async loadArtists(): Promise<void> {
    if(this.hasArtistLoaded) return
    this.isLoading = true
    try {
      this.artists = await searchArtists(this.searchKeyword)
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching artists: ', JSON.stringify(e));
    } finally {
      this.isLoading = false
      this.hasArtistLoaded = true
    }
  }
}