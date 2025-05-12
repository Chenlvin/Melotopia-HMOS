import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getPlayLists, PlayListOperation } from "../../api/playListApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayList } from "../../common/entities/PlayList"
import { User, User_INITIAL } from "../../common/entities/User"

/**
 * 添加至歌单Sheet
 */
const TAG = '[PlayListAddSheet] '

@Component
export struct PlayListAddSheet {
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER) user: User = User_INITIAL
  @StorageLink(StorageConstants.USER_PLAYLISTS) playLists: PlayList[] = []
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @State songId: number = -1
  @State showLikeList: boolean = true
  @Link isShow: boolean
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    try {
      if(this.playLists.length === 0 && this.user.data.account.id !== 0) {
        const result = await getPlayLists(0)
        this.playLists = result.playlist
      }
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching playlists: ', e)
    } finally {
      this.isLoading = false
    }
  }

  build() {
    Column({ space: 10 }) {
      Text('添加到歌单')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
      if(this.isLoading) {
        Column() {
          LoadingProgress().width(40)
        }
        .width('100%')
      }
      else {
        Refresh({ refreshing: this.isRefreshing }) {
          List() {
            ForEach(this.showLikeList ? this.playLists : this.playLists.slice(1), (item: PlayList, index) => {
              if (item.userId == this.user.data.profile.userId) {
                ListItem() {
                  Button() {
                    Row({ space: 10 }) {
                      Image(`${item.coverImgUrl}?param=256y256`)
                        .width(Constants.SIZE_IMG_CARD)
                        .borderRadius(Constants.RADIUS_IMG)
                        .padding(3)
                        .draggable(false)
                      Column({ space: 8 }) {
                        Text(item.name)
                          .fontSize(Constants.FONT_SIZE_COMMON)
                          .fontWeight(Constants.FONT_WEIGHT_BOLD)
                          .textAlign(TextAlign.Start)
                          .width('100%')
                        Text(`${item.trackCount} 首歌曲`)
                          .fontColor(Color.Gray)
                          .fontSize(12)
                          .textAlign(TextAlign.Start)
                          .width('100%')
                      }
                      .layoutWeight(1)
                    }
                    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
                    .width('100%')
                  }
                  .backgroundColor(Color.Transparent)
                  .borderRadius(Constants.RADIUS_IMG)
                  .type(ButtonType.Normal)
                  .width('100%')
                  .height(60)
                  .onClick(async () => {
                    try {
                      this.isShow = false
                      const result = await PlayListOperation('add', item.id, this.songId)
                      if (result) ToastUtil.showToast('成功添加到歌单')
                    } catch (e) {
                      LogUtil.error(TAG, 'Add to PlayList Error: ' + e)
                      ToastUtil.showToast(e.message)
                    }
                  })
                }
              }
            })
            ListItem().height(px2vp(this.bottomRectHeight) * 2)
          }
          .height('100%')
          .width('100%')
        }
        .height('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .onRefreshing(async () => {
          await this.handleRefresh()
        })
      }
    }
    .padding({ top:15 })
    .width('100%')
  }

  private async handleRefresh() {
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        await getPlayLists(0)
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
      }
    }
    this.isRefreshing = false
  }
}