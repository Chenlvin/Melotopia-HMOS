import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { Song, Song_INITIAL } from "../../common/entities/Song"
import { changeDuration } from "../../common/functions/common/convert"
import OrientationUtils from "../../common/utils/system/WindowUtils"
import { DownloadDialog } from "../dialog/DownloadDialog"
import { window } from "@kit.ArkUI"
import { AlbumParam, CommentParam, CommonParam } from "../../common/model/PageParams"
import { EmitterUtil } from "@pura/harmony-utils"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { COMMENT_TYPE } from "../../common/model/Enum"

@Component
export struct PlayerActionSheet {
  @Link isShow: boolean
  @Link isShowTimer: boolean
  @Link isShowAddSheet: boolean
  @Link isShowArtists: boolean
  @Link isShowSettings: boolean
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = Song_INITIAL
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_MODE) playmode: number = 1
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State orientationFlag: number = OrientationUtils.flag
  showOrientation: boolean = false
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
  })

  private setOrientation() {
    OrientationUtils.setOrientation(OrientationUtils.flag === 0 ?
    window.Orientation.AUTO_ROTATION_LANDSCAPE_RESTRICTED :
    window.Orientation.AUTO_ROTATION_UNSPECIFIED)
    this.orientationFlag = OrientationUtils.flag
  }

  build() {
      Scroll() {
        Column({ space: 10 }) {
          Column().height(Constants.PADDING_EDGE_DEFAULT)
          Row() {
            Text(this.song.name)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontWeight(FontWeight.Bold)
              .fontSize(Constants.FONT_SIZE_TITLE)
              .layoutWeight(1)
              .textAlign(TextAlign.Start)
              .alignSelf(ItemAlign.Start)
              .fontColor($r('app.color.app_red'))
            if(this.showOrientation) {
              Image($r('app.media.ic_public_rotate'))
                .fillColor(this.orientationFlag === 0 ? $r('app.color.reverse') : $r('app.color.app_red'))
                .width(Constants.SIZE_ICON_BUTTON_BAR)
                .onClick(() => {
                  this.isShow = false
                  setTimeout(() => {
                    this.setOrientation()
                  }, 600)
                })
            }
          }
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT})
          .width('100%')

          Column({ space: 10 }) {
            this.Item($r('app.media.ic_public_settings'), '播放设置', () => {
              this.isShow = false
              setTimeout(() => {
                this.isShowSettings = true
              }, 300)
            }, 24)
            if (this.song.id !== 0 && this.playmode !== 3) {
              this.Item($r('app.media.ic_playlist_add_icon'), '添加到歌单', () => {
                this.isShow = false
                setTimeout(() => {
                  this.isShowAddSheet = true
                }, 300)
              }, 24)
            }

            if(this.song.id !== 0) {
              this.Item($r('app.media.ic_arrow_down_o_icon'), '下载到本地', () => {
                this.isShow = false
                this.dialogController.open()
              }, 21)
            }

            this.Item($r('app.media.ic_timer_icon'), '定时关闭', () => {
              this.isShow = false
              setTimeout(() => {
                this.isShowTimer = true
              }, 300)
            }, 24)

            if(this.song.id !== 0) {
              this.Item($r('app.media.ic_public_message'), '歌曲评论', () => {
                this.isShow = false
                let param: CommonParam<CommentParam> = { pageName: 'CommentPage', param: {
                  id: this.song.id,
                  name: this.song.name,
                  type: COMMENT_TYPE.SONG
                }, remove: true }
                EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
                EmitterUtil.post(EmitterConstants.PLAYING_COVER_TOGGLE, false)
              }, 24)
            }

            if(this.playmode !== 3) {
              this.Item($r('app.media.ic_user_portrait'), `查看艺术家: ${this.artists}`, () => {
                this.isShow = false
                setTimeout(() => {
                  this.isShowArtists = true
                }, 300)
              })
            }

            if(this.song?.album?.id !== 0) {
              this.Item($r('app.media.ic_music_fill'), `查看专辑: ${this.song?.album?.name}`, () => {
                this.isShow = false
                let param: CommonParam<AlbumParam> = {
                  pageName: 'AlbumPage',
                  param: {
                    album: this.song.album
                  },
                  remove: true
                }
                EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
                EmitterUtil.post(EmitterConstants.PLAYING_COVER_TOGGLE, false)
              })
            }

            // this.Item($r('app.media.ic_public_share_filled'), `分享`, () => {
            //   this.isShow = false
            //   setTimeout(() => {
            //     ToastUtil.showToast(MsgConstants.DEVELOPING)
            //   }, 300)
            // })
          }
          Column().height(px2vp(this.bottomRectHeight)).width('100%')
        }
        .height('auto')
        .padding({
          left:  Constants.PADDING_MEDIUM,
          right: Constants.PADDING_MEDIUM
        })
      }
      .scrollable(ScrollDirection.Vertical)
      .padding({ top: 10 })
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .height('100%')
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
  }

  @Builder Item(icon: ResourceStr, name: string, action: () => void, size: number = 20) {
    Button() {
      Row({ space: 10 }) {
        Column() {
          Image(icon)
            .fillColor($r('app.color.reverse'))
            .height(size)
            .width(size)
        }
        .width(25)
        .justifyContent(FlexAlign.Center)
        Text(name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }
}
