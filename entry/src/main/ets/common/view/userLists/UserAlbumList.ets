import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import Constants from "../../constants/Constants";
import { StorageConstants } from "../../constants/StorageConstants";
import { getSubAlbum } from "../../../api/albumApi";
import { Album } from "../../entities/Album";
import { AlbumCard } from "../../../components/cards/AlbumCard";
import { PlayListSkeleton } from "../../../components/skeleton/Skeleton";

@Component
export struct UserAlbumList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER_SUB_ALBUM) subAlbums: Album[] = []
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getAlbumList') isLogged: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    try {
      await this.getAlbumList()
    } catch (e) {
      LogUtil.error('获取歌单列表失败')
    } finally {
      this.isLoading = false
    }
  }

  private async getAlbumList() {
    if(this.isLogged && this.subAlbums.length == 0) {
      this.isLoading = true
      const result = await getSubAlbum()
      this.subAlbums = result.data
      this.isLoading = false
    }
    else return
  }

  private async refreshContent() {
    if (!this.isLogged) return
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        const result = await getSubAlbum()
        this.subAlbums = []
        this.subAlbums = result.data
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
      }
    }
    this.isRefreshing = false
  }

  build() {
    Refresh({ refreshing: this.isRefreshing}) {
      List() {
        if(this.isLoading) {
          this.Loading()
        }
        else {
          ForEach(this.subAlbums, (item: Album, index) => {
            AlbumCard({ album: item })
          })
        }
        ListItem()
        ListItem().height(px2vp(this.bottomRectHeight) + 56 + Constants.HEIGHT_MINI + Constants.PADDING_EDGE_DEFAULT)
      }
      .lanes(this.breakpoint == 'lg' || this.breakpoint === 'md' ? 2 : 1)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
    .visibility(this.isLogged ? Visibility.Visible : Visibility.None)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onRefreshing(async () => {
      await this.refreshContent()
    })
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListSkeleton()
    })
  }
}