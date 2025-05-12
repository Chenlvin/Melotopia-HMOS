import { DialogUtil } from "@pura/harmony-utils"
import { getAlbumInfo } from "../../api/albumApi"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AlbumParam } from "../../common/model/PageParams"
import { SongCard } from "../../components/cards/SongCard"
import Constants from "../../common/constants/Constants"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"
import { AlbumInfoResult, AlbumInfoResult_INITIAL } from "../../common/entities/Album"
import { playListToQueue } from "../../common/functions/play/playListOp"
import { PLAYMODE } from "../../common/model/Enum"
import { PlayAllButton } from "../../components/buttons/PlayAllButton"
import { AlbumCommentSheet } from "../../components/sheets/AlbumCommentSheet"
import { PlayListSong } from "../../common/entities/PlayList"

@Component
export struct AlbumPage {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_HEIGHT) heightBp: string = 'sm'
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = ''
  @StorageLink(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @State songs: PlayListSong[] = []
  @State isLoading: boolean = true
  @State albumInfo: AlbumInfoResult = AlbumInfoResult_INITIAL
  @State isShowComment: boolean = false
  @State param: AlbumParam = {
    album: {
      id: 0,
      name: '',
      picUrl: '',
      artists: [],
      size: 0
    }
  }
  private commentSheetOptions: SheetOptions = {
    preferType: SheetType.BOTTOM,
    height: SheetSize.LARGE,
    dragBar: false,
    showClose: false,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.isShowComment = false }
  }

  async aboutToAppear(): Promise<void> {
    this.albumInfo = await getAlbumInfo(this.param.album.id)
    this.songs = this.albumInfo.songs
    this.isLoading = false
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        // Loading
        if(this.isLoading) {
          Column() {
            LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .width('100%')
          .height('100%')
          .padding({ bottom: px2vp(this.bottomRectHeight)})
          .justifyContent(FlexAlign.Center)
        } else {
          // Main List Content
          Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
            this.AlbumInfo()
            List() {
              ListItem() {
                this.PlayAllButton()
              }
              ListItem()
                .padding({ left: Constants.PADDING_EDGE_DEFAULT })
              ForEach(this.songs, (item: PlayListSong, index) => {
                SongCard({
                  playmode: PLAYMODE.ALBUM,
                  song: {
                    id: item.id,
                    artists: item.ar,
                    album: item.al,
                    name: item.name,
                    duration: item.dt,
                    alias: [],
                    fee: item.fee
                  },
                  index: index,
                  sid: index,
                  allowToAlbum: false,
                  listPlayAction: () => {
                    playListToQueue(this.songs, index)
                  }
                })
              })
              ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
            }
            .height('100%')
            .width('100%')
            .layoutWeight(1)
            .lanes(this.breakpoint === 'sm' ? 1 : 2)
            .scrollBar(BarState.Auto)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            .cachedCount(10)
            .visibility(this.isLoading ? Visibility.None : Visibility.Visible)
            .edgeEffect(EdgeEffect.Spring)
            .backToTop(true)
          }
        }

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.background'))
    .title('专辑')
    .menus([{
      icon: $r('app.media.ic_public_message'),
      value: 'Comment',
      action: () => {
        this.isShowComment = true
      }
    }])
  }

  @Builder PlayAllButton() {
    if(this.isPlayerLoading) {
      Column() {
        LoadingProgress()
          .width(Constants.SIZE_LOADING_PROGRESS_CARD)
      }
      .padding({ left: Constants.PADDING_EDGE_TEXT})
      .height(Constants.HEIGHT_TEXT_BUTTON)
      .justifyContent(FlexAlign.Center)
    } else {
      PlayAllButton({
        count: this.songs.length,
        clickAction: () => {
          this.isPlayerLoading = true
          playListToQueue(this.songs, 0)
          setTimeout(() => {
            this.isPlayerLoading = false
          }, 500)
        }
      })
    }
  }

  @Builder CommentSheet() {
    AlbumCommentSheet({ album: this.param.album })
  }

  @Builder AlbumInfo() {
    Row({ space: Constants.PADDING_EDGE_DEFAULT }) {
      Image(this.albumInfo.album.picUrl + '?param=512y512')
        .width(120)
        .aspectRatio(1)
        .borderRadius(Constants.RADIUS_CARD)
      Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
        Text(this.albumInfo.album.name)
          .textStyle(Constants.FONT_SIZE_TITLE, Constants.FONT_WEIGHT_BOLD)
          .fontColor($r('app.color.reverse'))
        Text(`发行商: ${this.albumInfo.album.company}`)
          .textStyle(12)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .visibility(this.albumInfo.album.company ? Visibility.Visible : Visibility.None)
        Text(this.albumInfo.album.description)
          .textStyle(12)
          .maxLines(3)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
          .onClick(() => {
            DialogUtil.showConfirmDialog({
              title: this.albumInfo.album.name,
              message: this.albumInfo.album.description
            })
          })
      }
      .layoutWeight(1)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .bindSheet(this.isShowComment, this.CommentSheet, this.commentSheetOptions)
  }
}

@Extend(Text) function textStyle(size: number = Constants.FONT_SIZE_COMMON, bold: number = FontWeight.Medium) {
  .width('100%')
  .fontWeight(bold)
  .fontSize(size)
  .fontColor(Color.Gray)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}