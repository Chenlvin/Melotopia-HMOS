import { Song, Song_INITIAL } from "../../common/entities/Song"
import { getArtists } from "../../common/functions/common/convert"
import { PlayList, PlayList_INITIAL } from "../../common/entities/PlayList"
import Constants from "../../common/constants/Constants"
import { cleanLastPlayInfo } from "../../common/functions/play/playListOp"
import { ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../../common/constants/StorageConstants"
import VibratorUtils from "../../common/utils/system/VibratorUtils"
import { ArtistsSheet } from "../sheets/ArtistsSheet"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { playQueue } from "../../common/functions/play/playControl"
import { SongInfoSheet } from "../sheets/SongInfoSheet"
import { PlayListAddSheet } from "../sheets/PlayListAddSheet"
import { PLAYMODE } from "../../common/model/Enum"

@Component
export struct SongCard {
  @StorageProp(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @StorageProp(StorageConstants.PLAY_SONG) playSong: Song = Song_INITIAL
  @State index: number = 0
  @State sid: number = -1
  @State isShowSheet: boolean = false
  @State isShowAddSheet: boolean = false
  @State isShowArtistSheet: boolean = false
  @State playmode: PLAYMODE = PLAYMODE.SINGLE
  playlist: PlayList = PlayList_INITIAL
  song: Song = Song_INITIAL
  artists: string = ''
  picUrl: string = ''
  reason: string = ''
  allowToArtist: boolean = true
  allowToAlbum: boolean = true
  moreVisible: boolean = true
  listPlayAction: () => void = () => {}


  async aboutToAppear(): Promise<void> {
    if(this.song.artists[0].id == -1) {
     this.artists = '未知'
      this.song.artists[0] = {"id": 0, "name": '未知'}
    }
    this.artists = getArtists(this.song.artists)
  }


  private handleClick() {
    if(this.song.id == this.playSong.id) { // 当前正在播放
      return
    }
    else if(this.playmode !== PLAYMODE.LOCAL && this.playmode !== PLAYMODE.SINGLE) {
      this.listPlayAction()
    } else {
      this.playSingleSong()
    }
  }

  private playSingleSong() {
    if(!this.isPlayerLoading) {
      cleanLastPlayInfo()
      AppStorage.setOrCreate(StorageConstants.IS_PLAYER_LOADING, true)
      PlayQueueUtils.queueAdd(this.playmode, this.song, this.artists, '', this.picUrl ?? '')
      PlayQueueUtils.setIndex(PlayQueueUtils.currentQueueIndex + 1)
      playQueue(PlayQueueUtils.currentQueueIndex)
      setTimeout(() => {
        AppStorage.setOrCreate('isPlayerLoading', false)
      }, 500)
    } else {
      ToastUtil.showToast('当前有正在加载的播放任务，请稍后再试')
    }
  }

  build() {
    Button() {
      Row() {
        Row() {
          Text(`${this.sid + 1}`)
            .width(40)
            .fontSize(Constants.FONT_SIZE_BAR)
            .fontColor(Color.Gray)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .visibility(this.sid === -1 ? Visibility.None : Visibility.Visible)
            .padding({ right: 5 })
          if(this.picUrl) {
            Image(this.picUrl + '?param=128y128')
              .width(Constants.SIZE_IMG_CARD)
              .padding(3)
              .aspectRatio(1)
              .borderRadius(5)
              .draggable(false)
          }
          Column({ space: 5 }) {
            Row({ space: 5 }) {
              Text(this.song.name)
                .textStyle(16)
                .fontColor(this.song.id == this.playSong.id ? $r('app.color.app_red') : $r('app.color.reverse'))
                .fontWeight(this.song.id == this.playSong.id ? FontWeight.Bold : FontWeight.Medium)
              if(this.song.alias?.length > 0) {
                Text(`(${this.song.alias[0]})`)
                  .layoutWeight(1)
                  .fontSize(Constants.FONT_SIZE_COMMON)
                  .fontColor(Color.Gray)
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
            }
            .width('100%')
            .bindSheet(this.isShowAddSheet, this.AddToPlaylistSheet(), {
              preferType: SheetType.CENTER,
              height: '60%',
              dragBar: false,
              showClose: false,
              backgroundColor: Color.Transparent,
              blurStyle: BlurStyle.Regular,
              onDisappear: (() => { this.isShowAddSheet = false})
            })

            Row({ space: 5 }) {
              if(this.reason) {
                Text(this.reason)
                  .reasonText()
              }
              if(this.song.fee != 8 && this.song.fee != 0) {
                Text(this.song.fee == 1 ? ' VIP ' : '单曲付费')
                  .reasonText()
              }
              Text(this.artists).textStyle(12).fontColor(Color.Gray).layoutWeight(1)
            }
            .width('100%')
            .bindSheet(this.isShowArtistSheet, this.ArtistsSheet(), {
              preferType: SheetType.CENTER,
              height: SheetSize.FIT_CONTENT,
              dragBar: false,
              showClose: false,
              backgroundColor: Color.Transparent,
              blurStyle: BlurStyle.Regular,
              onDisappear: () => { this.isShowArtistSheet = false }
            })
          }
          .layoutWeight(1)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT })
          .width(`100%`)
        }
        .layoutWeight(1)

        /**
         * ShowSheet
         */
        Image($r('app.media.ic_public_more_list'))
          .draggable(false)
          .fillColor($r('app.color.reverse'))
          .width(20)
          .visibility(this.moreVisible ? Visibility.Visible : Visibility.None)
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
          .onClick(() => { this.isShowSheet = true })
          .bindSheet(this.isShowSheet, this.InfoSheet(), {
            preferType: SheetType.CENTER,
            height: SheetSize.FIT_CONTENT,
            dragBar: false,
            showClose: false,
            backgroundColor: Color.Transparent,
            blurStyle: BlurStyle.Regular,
            onDisappear: () => { this.isShowSheet = false }
          })
      }
      .height(60)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: this.sid === -1 ? 10 : 5 , right: 20 })
    // Card 点击
    .onClick(() => { this.handleClick() })
    .gesture(
      LongPressGesture({
        duration: 500
      }).onAction(() => {
        VibratorUtils.startCount('sharp', 1, 100)
        this.isShowSheet = true
      })
    )
  }

  @Builder InfoSheet() {
    SongInfoSheet({
      song: this.song,
      artists: this.artists,
      playlist: this.playlist,
      picUrl: this.picUrl,
      index: this.index,
      isShow: this.isShowSheet,
      isShowArtistsSheet: this.isShowArtistSheet,
      isShowAddSheet: this.isShowAddSheet,
      allowToArtist: this.allowToArtist,
      allowToAlbum: this.allowToAlbum,
      playmode: this.playmode,
      listAction: this.listPlayAction
    })
  }

  @Builder ArtistsSheet() {
    ArtistsSheet({
      isShow: this.isShowArtistSheet,
      isShowCover: this.isShowArtistSheet,
      artists: this.song.artists
    })
  }

  @Builder AddToPlaylistSheet() {
    PlayListAddSheet({
      songId: this.song.id,
      isShow: this.isShowAddSheet
    })
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}

@Extend(Text) function reasonText() {
  .fontColor('#ffff3232')
  .fontSize(10)
  .padding(2)
  .backgroundColor('#ffffd2d2')
  .borderRadius(5)
}


