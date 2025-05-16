import { DialogUtil, EmitterUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayListOperation } from "../../api/playListApi"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AlbumParam, CommentParam, CommonParam } from "../../common/model/PageParams"
import { PlayList, PlayList_INITIAL } from "../../common/entities/PlayList"
import { Song, Song_INITIAL } from "../../common/entities/Song"
import { User, User_INITIAL } from "../../common/entities/User"
import { changeDuration } from "../../common/functions/common/convert"
import { playQueue } from "../../common/functions/play/playControl"
import { cleanLastPlayInfo } from "../../common/functions/play/playListOp"
import { COMMENT_TYPE, PLAYMODE } from "../../common/model/Enum"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { DownloadDialog } from "../dialog/DownloadDialog"

@Component
export struct SongInfoSheet {
  song: Song = Song_INITIAL
  artists: string = ''
  picUrl: string | ResourceStr = ''
  playlist: PlayList = PlayList_INITIAL
  index: number = 0
  allowToArtist: boolean = true
  allowToAlbum: boolean = true
  playmode: number = 1
  listAction: () => void = () => {}
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.USER) user: User = User_INITIAL
  @Link isShow: boolean
  @Link isShowArtistsSheet: boolean
  @Link isShowAddSheet: boolean
  downloadDialogController: CustomDialogController = new CustomDialogController({
    builder: DownloadDialog({
      song: this.song,
      picUrl: this.picUrl,
      artists: this.artists,
      duration: changeDuration(this.song.duration)
    }),
    cornerRadius: Constants.RADIUS_CARD
  })

  private addToQueue() {
    cleanLastPlayInfo()
    PlayQueueUtils.queueAdd(this.playmode, this.song, this.artists, '', this.picUrl ?? $r('app.media.ic_public_music'))
    ToastUtil.showToast('成功添加到下一首播放')
  }

  private playSingleSong() {
    if(!this.isPlayerLoading) {
      cleanLastPlayInfo()
      AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, true)
      PlayQueueUtils.queueAdd(1, this.song, this.artists, '')
      PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
      playQueue(PlayQueueUtils.currentQueueIndex)
      setTimeout(() => {
        AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, false)
      }, 500)
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    }
  }

  private async playWithPlayList() {
    if(!this.isPlayerLoading) {
      this.isPlayerLoading = true
      this.listAction()
      this.isPlayerLoading = false
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    }
  }

  private async deleteFromPlaylist() {
    DialogUtil.showPrimaryDialog({
      title: '从歌单删除歌曲',
      message: `${this.song.name}`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          try {
            await PlayListOperation('del', this.playlist.id, this.song.id)
            EmitterUtil.post(EmitterConstants.EMITTER_DELETE_FROM_PLAYLIST, this.index)
            cleanLastPlayInfo()
            ToastUtil.showToast('删除成功')
          } catch (e) {
            ToastUtil.showToast('删除失败: ' + e)
          }
        }
      }
    })
  }

  build() {
    List() {
      ListItem() {
        Text() {
          Span(this.song.name)
          if(this.song.alias[0] !== undefined) {
            Span(` (${this.song.alias[0]})`)
              .fontColor(Color.Gray)
          }
        }
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontColor($r('app.color.reverse'))
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .width('100%')
          .padding({
            top: Constants.PADDING_EDGE_DEFAULT,
            bottom: 20,
            left: Constants.PADDING_EDGE_DEFAULT,
            right: Constants.PADDING_EDGE_DEFAULT
          })
      }
      ListItem() {
        this.Item($r('app.media.ic_public_add_filled'), '下一首播放', () => { this.addToQueue() })
      }
      ListItem() {
        this.Item($r('app.media.ic_public_play_norm'), '单曲播放', () => { this.playSingleSong() })
      }
      if(this.playmode !== PLAYMODE.SINGLE) {
        ListItem() {
          this.Item($r('app.media.ic_play_fill'), '随列表播放', () => { this.playWithPlayList() })
        }
      }
      if(this.playmode !== 3) {
        if(this.song.id !== 0 && this.song?.artists[0].id !== 0) {
          this.Item($r('app.media.ic_public_message'), '歌曲评论', () => {
            let param: CommonParam<CommentParam> = { pageName: 'CommentPage', param: {
              id: this.song.id,
              name: this.song.name,
              type: COMMENT_TYPE.SONG
            }, remove: true }
            EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
          })
        }
        if(this.allowToArtist && this.song?.artists[0].id !== 0) {
          ListItem() {
            this.Item($r('app.media.ic_user_portrait'), '查看歌手', () => { this.isShowArtistsSheet = true })
          }
        }
        if(this.song.album?.id !== 0 && this.allowToAlbum) {
          ListItem() {
            this.Item($r('app.media.ic_music_fill'), `查看专辑: ${this.song.album.name}`, () => {
              let param: CommonParam<AlbumParam> = {
                pageName: 'AlbumPage',
                param: {
                  album: this.song.album
                },
                remove: true
              }
              EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
            })
          }
        }
        if(this.song?.artists[0].id !== 0) {
          ListItem() {
            this.Item($r('app.media.ic_files_new_folder'), '添加到歌单', () => { this.isShowAddSheet = true })
          }
        }
      }
      ListItem() {
        this.Item($r('app.media.ic_public_cloud_download'), '下载到本地曲库', () => { this.downloadDialogController.open() })
      }
      if(this.user.data.account.id === this.playlist.userId) {
        ListItem() {
          this.Item($r('app.media.ic_public_delete'), '从歌单中删除', () => { this.deleteFromPlaylist() }, $r('app.color.app_red'))
        }
      }


      ListItem().height(px2vp(this.bottomRectHeight))
    }
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .height('auto')
    .width('100%')
    .scrollBar(BarState.Off)
    .divider({ strokeWidth: 0.1, startMargin: 45, endMargin: 20, color: Color.Gray })
    .padding({
      left:  Constants.PADDING_EDGE_DEFAULT,
      right: Constants.PADDING_EDGE_DEFAULT,
      top: Constants.PADDING_EDGE_DEFAULT,
    })
  }

  @Builder Item(icon: ResourceStr, name: string, action: () => void, color: string | ResourceStr = $r('app.color.reverse')) {
    Button() {
      Row({ space: 10 }) {
        Column() {
          Image(icon)
            .fillColor(color)
            .height(20)
            .width(20)
        }
        .width(25)
        .justifyContent(FlexAlign.Center)
        Text(name)
          .fontSize(Constants.FONT_SIZE_COMMON + 2)
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .padding({
      top: 15,
      bottom: 15,
      left: Constants.PADDING_EDGE_DEFAULT,
      right: Constants.PADDING_EDGE_DEFAULT
    })
    .onClick(() => {
      this.isShow = false
      setTimeout(() => {
        action()
      }, 300)
    })
  }
}