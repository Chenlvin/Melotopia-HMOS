import Constants from "../../common/constants/Constants"
import FileUtils from "../../common/utils/file/FileUtils"
import { MatchSongSheet } from "../sheets/MatchSongSheet"
import { getLocalSongArtistsString } from "../../common/functions/common/get"
import { FileCardClickMenu } from "../menu/FileCardClickMenu"
import { LocalSong, LocalSong_INITIAL } from "../../common/entities/Song"

/**
 * 文件卡片组件
 */
@Component
export struct FileCard {
  @State localSong: LocalSong = LocalSong_INITIAL
  @State showMatchSheet: boolean = false
  @State artistsString: string = ''
  listPlayAction: () => void = () => {}

  private matchSheetOptions: SheetOptions = {
    preferType: SheetType.CENTER,
    height: '70%',
    dragBar: false,
    showClose: false,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.showMatchSheet = false }
  }

  async aboutToAppear() {
    this.artistsString = getLocalSongArtistsString(this.localSong.artists)
  }

  build() {
    Button() {
      Row({ space: 5 }) {
        Image(this.localSong.songId == 0 ? $r('app.media.ic_files_audio') : `file://${FileUtils.getFilesDir()}/pic/${this.localSong.songId}.jpg`)
          .width(Constants.SIZE_IMG_CARD)
          .borderRadius(Constants.RADIUS_IMG)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT })
        Column({ space: 5 }) {
          Text(this.localSong.name)
            .textStyle(16)
            .fontWeight(FontWeight.Medium)
          Text(this.artistsString)
            .textStyle(12)
            .fontColor(Color.Gray)
        }
        .layoutWeight(1)
      }
    }
    .type(ButtonType.Normal)
    .backgroundColor($r('app.color.main'))
    .borderRadius(10)
    .width('100%')
    .height(60)
    .bindMenu(this.ClickMenu())
    .bindSheet(this.showMatchSheet, this.MatchSheet, this.matchSheetOptions)
  }

  @Builder
  ClickMenu() {
    FileCardClickMenu({
      localSong: this.localSong,
      artistsString: this.artistsString,
      showMatchSheet: this.showMatchSheet,
      playWithList: this.listPlayAction
    })
  }

  @Builder
  MatchSheet() {
    MatchSongSheet({
      showMatchSheet: this.showMatchSheet,
      localSong: this.localSong
    })
  }
}

@Extend(Text) function textStyle(size: number) {
  .width('100%')
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .padding({ left: 10, right: 10 })
}