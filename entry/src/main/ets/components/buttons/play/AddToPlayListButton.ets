import Constants from "../../../common/constants/Constants"
import { StorageConstants } from "../../../common/constants/StorageConstants"
import { Song, Song_INITIAL } from "../../../common/entities/Song"
import { PlayListAddSheet } from "../../sheets/PlayListAddSheet"

@Component
export struct AddToPlayListButton {
  @State isShowAddSheet: boolean = false
  @State songId: number = -1

  build() {
    Button() {
      Row() {
        Text('添加到歌单')
          .height('100%')
          .fontColor(Color.White)
          .padding({ left: 10, right: 10 })
          .textAlign(TextAlign.Center)
      }
    }
    .type(ButtonType.Normal)
    .height('100%')
    .backgroundColor('#ff176b81')
    .onClick(() => {
      this.isShowAddSheet = !this.isShowAddSheet
    })
    .bindSheet(this.isShowAddSheet, this.Sheet(), {
      preferType: SheetType.CENTER,
      height: '80%',
      dragBar: false,
      showClose: false,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => { this.isShowAddSheet = false }
    })
  }

  @Builder Sheet() {
    PlayListAddSheet({ isShow: this.isShowAddSheet, songId: this.songId })
  }
}

@Component
export struct AddToPlayListCircleButton {
  @Link isShowAddSheet: boolean
  @Link song: Song
  @State imgColor: Color | ResourceStr = $r('app.color.reverse')
  @State imgHeight: number | string = Constants.SIZE_ICON_BUTTON_BAR
  isLarge: boolean = false

  build() {
    Image($r('app.media.ic_playlist_add_icon'))
      .height(this.imgHeight)
      .aspectRatio(1)
      .fillColor(this.imgColor)
      .draggable(false)
      .backgroundColor(Color.Transparent)
      .onClick(() => {
        this.isShowAddSheet = !this.isShowAddSheet
      })
      .bindSheet(this.isShowAddSheet, this.Sheet(), {
        preferType: SheetType.CENTER,
        height: this.isLarge ? SheetSize.LARGE : '80%',
        dragBar: false,
        showClose: false,
        backgroundColor: Color.Transparent,
        blurStyle: BlurStyle.Regular,
        onDisappear: () => {
          this.isShowAddSheet = false
        }
      })
  }

  @Builder Sheet() {
    PlayListAddSheet({
      isShow: this.isShowAddSheet,
      songId: this.song.id,
      showLikeList: false
    })
  }
}