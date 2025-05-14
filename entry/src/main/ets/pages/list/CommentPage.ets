import { LazyData } from "@pie/lazy-data"
import { getComment } from "../../api/commentApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { CommentParam } from "../../common/model/PageParams"
import { Comment } from "../../common/entities/Comment"
import { ClickToLoadButton, LoadingMoreButton } from "../../components/buttons/LoadMoreButtons"
import { CommentCard } from "../../components/cards/CommentCard"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"

@Component
export struct CommentPage {
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State param: CommentParam = { id: 0, name: '', type: 0 }
  @State comments: Comment[] = []
  @State isLoading: boolean = true
  @State isLoadingMore: boolean = false
  @State currentPage: number = 1
  @State sortType: 1 | 2 | 3 = 3 // 1-按推荐排序, 2-按热度排序, 3-按时间排序
  @State dataSource: LazyData<Comment> = new LazyData()
  @State hasMore: boolean = true
  showMiniPlayer: boolean = true
  pageSize: number = 30

  async aboutToAppear(): Promise<void> {
    try {
      if(this.param.id !== 0) {
        this.isLoading = true
        await this.loadComments()
      }
    } catch (e) {
      throw new Error(e.stack)
    } finally {
      this.isLoading = false
    }
  }

  private async loadComments() {
    const cursor = this.currentPage > 1 && this.comments.length > 0
      ? this.comments[this.comments.length - 1].time
      : undefined

    if(this.currentPage > 1) this.isLoadingMore = true
    let temp = (await getComment(
      this.param.id,
      this.param.type,
      this.currentPage,
      this.pageSize,
      this.sortType,
      cursor
    ))
      .data.comments

    if(temp.length < this.pageSize) this.hasMore = false

    this.comments = [...this.comments, ...temp]
    this.dataSource.setData(this.comments)
    this.dataSource.notifyDataReload()

    this.currentPage++
    this.isLoadingMore = false
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .padding({ bottom: px2vp(this.bottomRectHeight) })
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: Constants.PADDING_MEDIUM }) {
            if(this.comments.length === 0) {
              ListItem() {
                Text('暂无评论')
                  .width('100%')
                  .fontSize(Constants.FONT_SIZE_COMMON)
                  .fontColor(Color.Gray)
                  .fontWeight(FontWeight.Bold)
                  .textAlign(TextAlign.Center)
                  .padding(Constants.PADDING_EDGE_TEXT)
              }
            } else {
              LazyForEach(this.dataSource, (item: Comment) => {
                CommentCard({ comment: item })
                  .padding({ left: 20, right: 20 })
              })
            }

            if(this.isLoadingMore) {
              LoadingMoreButton()
            } else if(this.hasMore) {
              ClickToLoadButton()
                .padding({ left: Constants.PADDING_MEDIUM, right: Constants.PADDING_MEDIUM })
                .onClick(async () => {
                await this.loadComments()
              })
            }

            ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
          }
          .height('100%')
          .width('100%')
          .scrollBar(BarState.Auto)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          .backToTop(true)
          .cachedCount(5)
        }

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .visibility(this.breakpoint !== 'lg' && this.showMiniPlayer ? Visibility.Visible : Visibility.None)
      }
      .height('100%')
      .width('100%')
    }
    .title(`评论 - ${this.param.name}`)
    .backgroundColor($r('app.color.background'))
  }
}