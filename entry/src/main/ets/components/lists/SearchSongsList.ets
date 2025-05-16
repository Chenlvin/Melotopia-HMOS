import { EmitterUtil, LogUtil } from "@pura/harmony-utils"
import { searchSongs } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { Song } from "../../common/entities/Song"
import { ClickToLoadButton, LoadingMoreButton, NoMoreButton } from "../buttons/LoadMoreButtons"
import { AddToPlayListButton } from "../buttons/AddToPlayListButton"
import { SongCard } from "../cards/SongCard"

/**
 * 搜索结果——单曲列表
 */
const TAG = "[SearchSongsList] "

@Component
export struct SearchSongsList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @Link @Watch('handleSearch') searchKeyword: string
  @State songList: Array<Song> = []
  @State songOffset: number = 0
  @State hasMoreSongs: boolean = true
  @State hasSongLoaded: boolean = false
  @State isLoading: boolean = false
  @State isLoadingMore: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.loadSongs(0)
    }
  }

  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(EmitterConstants.EMITTER_SEARCH)
  }

  async handleSearch() {
    this.songList = []
    this.songOffset = 0
    await this.loadSongs(0)
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
      List() {
        ForEach(this.songList, (item: Song) => {
          ListItem() {
            SongCard({ song: item })
          }
          .translate({ y: -40 })
          .animation({
            duration: 600,
            curve: Curve.LinearOutSlowIn
          })
          .translate({ y: 0 })
        })
        // 添加加载更多
        if (this.isLoadingMore) {
          ListItem() {
            LoadingMoreButton()
          }
        } else if (this.hasMoreSongs && this.searchKeyword) {
          ListItem() {
            ClickToLoadButton()
              .padding({ left: Constants.PADDING_MEDIUM, right: Constants.PADDING_MEDIUM })
              .onClick(() => {
                this.loadSongs(this.songOffset)
              })
          }
        } else if (!this.hasMoreSongs) {
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

  async loadSongs(offset: number): Promise<void> {
    if (!this.hasMoreSongs && offset != 0) return // 没有更多歌曲直接返回
    if (offset == 0) {
      this.isLoading = true // 初次加载
    } else {
      this.isLoadingMore = true // 加载更多
    }
    try {
      const result = await searchSongs(this.searchKeyword, offset)
      this.songList = [...this.songList, ...result.list] // 合并歌曲列表
      this.songOffset += 30
      this.hasMoreSongs = result.hasMore
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching songs: ', JSON.stringify(e))
    } finally {
      this.isLoading = false
      this.isLoadingMore = false
      this.hasSongLoaded = true
    }
  }
}