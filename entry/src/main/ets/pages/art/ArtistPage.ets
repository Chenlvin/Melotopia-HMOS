import { LazyData } from "@pie/lazy-data"
import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { getArtistInfo } from "../../api/artistApi"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { ArtistParam } from "../../common/model/PageParams"
import { SongCard } from "../../components/cards/SongCard"
import { BottomBarComponent } from "../../components/play/BottomBarComponent"
import { PLAYMODE } from "../../common/model/Enum"
import { PlayAllButton } from "../../components/buttons/PlayAllButton"
import { playListToQueue } from "../../common/functions/play/playListOp"
import { PlayListSong } from "../../common/entities/PlayList"
import { ArtistInfo, ArtistInfo_INITIAL } from "../../common/entities/Artists"

@Component
export struct ArtistPage {
  @State param: ArtistParam = {
    artist: {
      id: 0,
      name: ''
    }
  }
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State artist: ArtistInfo = ArtistInfo_INITIAL
  @State isLoading: boolean = true
  @State showTitleBar: boolean = false
  @State dataSource: LazyData<PlayListSong> = new LazyData()

  async aboutToAppear(): Promise<void> {
    if(this.param.artist.id !== 0) {
      await this.loadArtist()
    }
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        List() {
          ListItem() {
            Column({ space: 10 }) {
              Stack({ alignContent: Alignment.BottomStart }) {
                Image(this.artist.artist.picUrl + '?param=512y512')
                  .width('100%')
                  .height('100%')
                  .autoResize(true)
                  .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
                Column({ space: 10 }) {
                  Text(this.artist.artist.name)
                    .textStyle(Constants.FONT_SIZE_COVER)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.White)
                    .textShadow({ radius: 20 })
                  if(this.artist.artist.alias.length > 0) {
                    Text(`${this.artist.artist.alias.join(', ')}`)
                      .textStyle()
                      .maxLines(1)
                      .fontSize(Constants.FONT_SIZE_TITLE)
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                      .fontStyle(FontStyle.Italic)
                      .textShadow({ radius: 20 })
                  }
                }
                .padding(Constants.PADDING_EDGE_DEFAULT)
              }
              .width('100%')
              .aspectRatio(1.3)
              .constraintSize({
                minHeight: 0,
                maxHeight: 350
              })

              Row() {
                Text(this.artist.artist.briefDesc)
                  .textStyle(12)
                  .maxLines(3)
                  .layoutWeight(1)
                Image($r('app.media.ic_public_arrow_right'))
                  .width(Constants.FONT_SIZE_TITLE)
                  .aspectRatio(1)
                  .fillColor($r('app.color.reverse'))
              }
              .alignSelf(ItemAlign.End)
              .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
              .onClick(() => {
                DialogUtil.showConfirmDialog({
                  title: this.artist.artist.name,
                  message: this.artist.artist.briefDesc
                })
              })
              .padding({ left: 20, right: 20 })

            }
            .padding({ bottom: Constants.PADDING_EDGE_TEXT })
          }

          ListItem() {
            Text('TA的热门单曲')
              .fontWeight(FontWeight.Bold)
              .fontSize(Constants.FONT_SIZE_TITLE)
              .fontColor($r('app.color.reverse'))
              .padding({ left: 20, bottom: Constants.PADDING_EDGE_DEFAULT })
          }
          PlayAllButton({
            count: this.artist.hotSongs.length,
            clickAction: () => { playListToQueue(this.artist.hotSongs, 0) }
          })
          LazyForEach(this.dataSource, (item: PlayListSong, index) => {
            SongCard({
              playmode: PLAYMODE.PLAYLIST,
              song: {
                id: item.id,
                artists: item.ar,
                album: item.al,
                name: item.name,
                duration: item.dt,
                alias: [],
                fee: item.fee
              },
              allowToArtist: false,
              listPlayAction: () => {
                playListToQueue(this.artist.hotSongs, index)
              }
            })
          })
          ListItem()
            .height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
        }
        .height('100%')
        .width('100%')
        .scrollBar(BarState.Auto)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .cachedCount(10)
        .visibility(this.isLoading ? Visibility.None : Visibility.Visible)
        .edgeEffect(EdgeEffect.None)
        .backToTop(true)
        .onScrollIndex((start) => {
          animateTo({ duration: 500, curve: Curve.Ease }, () => {
            if(start === 0) {
              this.showTitleBar = false
            } else {
              this.showTitleBar = true
            }
          })
        })

        Column() {
          LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .height('100%')
        .visibility(this.isLoading ? Visibility.Visible : Visibility.Hidden)

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height('100%')
    }
    .title(this.showTitleBar ? this.param.artist.name : '',
      {
        backgroundColor: Color.Transparent,
        barStyle: BarStyle.STACK,
        backgroundBlurStyle: this.showTitleBar ? BlurStyle.Regular : BlurStyle.NONE
      })
    .backgroundColor($r('app.color.background'))
  }

  private async loadArtist() {
    this.isLoading = true
    try {
      this.artist = await getArtistInfo(this.param.artist.id)
      this.dataSource.setData(this.artist.hotSongs)
      this.dataSource.notifyDataReload()
    } catch (e) {
      ToastUtil.showToast('获取歌手信息失败')
    } finally {
      this.isLoading = false
    }
  }
}

@Extend(Text) function textStyle(size: number = Constants.FONT_SIZE_COMMON) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .width('100%')
  .textAlign(TextAlign.Start)
  .maxLines(2)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}