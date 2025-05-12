import { LogUtil } from "@pura/harmony-utils"
import { searchAlbums } from "../../api/albumApi"
import Constants from "../../common/constants/Constants"
import { Album } from "../../common/entities/Album"
import { AlbumCard } from "../cards/AlbumCard"

/**
 * 专辑搜索结果列表
 */
const TAG = "[SearchAlbumList] "

@Component
export struct SearchAlbumList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State albums: Array<Album> = []
  @Link @Watch('handleSearch') searchKeyword: string
  @State hasLoaded: boolean = false
  @State isLoading: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.loadAlbums()
    }
  }

  async handleSearch() {
    this.albums = []
    await this.loadAlbums()
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
        ForEach(this.albums, (item: Album) => {
          ListItem() {
            AlbumCard({ album: item })
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

  async loadAlbums(): Promise<void> {
    if(this.hasLoaded) return
    this.isLoading = true
    try {
      this.albums = await searchAlbums(this.searchKeyword)
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching Albums: ', JSON.stringify(e))
    } finally {
      this.isLoading = false
      this.hasLoaded = true
    }
  }
}