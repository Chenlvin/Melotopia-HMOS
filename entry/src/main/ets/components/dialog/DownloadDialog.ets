import { Song, Song_INITIAL } from "../../common/entities/Song"
import { PlayConstants } from "../../common/constants/PlayConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import DownloadUtils from "../../common/utils/file/DownloadUtils"

@CustomDialog
export struct DownloadDialog {
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @State song: Song = Song_INITIAL
  @State picUrl: string | ResourceStr = ''
  @State artists: string = ''
  @State duration: string = ''
  @State quality: number = 3
  fileSize: number = -1

  controller: CustomDialogController

  build() {
    Scroll() {
      Column({ space: Constants.PADDING_MEDIUM }) {
        Column({ space: 5 }) {
          Text(this.song.name).textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
          Text(this.artists).textStyle(Constants.FONT_SIZE_COMMON).fontColor(Color.Gray)
        }
        .width('100%')

        Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
          .selected(this.quality)
          .value(this.quality ? PlayConstants.QUALITY_NAME[this.quality] : '标准')
          .constraintSize({
            minHeight: 0,
            maxHeight: '100%'
          })
          .height(45)
          .onSelect((index) => {
            if(index != this.quality) {
              this.quality = index
            }
          })

        Divider()

        if(this.isLogged) {
          Button('添加至下载列表').ButtonStyle()
            .onClick(async () => {
              this.controller.close()
              DownloadUtils.addItem([this.song], this.quality)
            })
        } else {
          Text('请登录后再试')
            .fontColor($r('app.color.reverse'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(Constants.FONT_WEIGHT_BOLD)
        }

      }
      .padding(Constants.PADDING_MEDIUM)
    }
    .scrollBar(BarState.Off)
  }
}


@CustomDialog
export struct BatchDownloadDialog {
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @State quality: number = 3
  songs: Song[] = []
  controller: CustomDialogController

  build() {
    Scroll() {
      Column({ space: Constants.PADDING_MEDIUM }) {
        Column({ space: 5 }) {
          Text('批量下载').textStyle(18).fontWeight(FontWeight.Bold)
          Text(`${this.songs.length} 首歌曲`).textStyle(16).fontColor(Color.Gray)
        }
        .width('100%')

        Select([{ value: '标准' }, { value: '高' }, { value: '极高' }, { value: '无损' }])
          .selected(this.quality)
          .value(this.quality ? PlayConstants.QUALITY_NAME[this.quality] : '标准')
          .constraintSize({
            minHeight: 0,
            maxHeight: '100%'
          })
          .height(45)
          .onSelect((index) => {
            if(index != this.quality) {
              this.quality = index
            }
          })

        Divider()

        if(this.isLogged) {
          Button('添加至下载列表').ButtonStyle()
            .onClick(async () => {
              this.controller.close()
              DownloadUtils.addItem(this.songs, this.quality)
            })
        } else {
          Text('请登录后再试')
            .fontColor($r('app.color.reverse'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(Constants.FONT_WEIGHT_BOLD)
        }
      }
      .padding(Constants.PADDING_MEDIUM)
    }
    .scrollBar(BarState.Off)
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .textAlign(TextAlign.Center)
}

@Extend(Button) function ButtonStyle() {
  .backgroundColor(Color.Transparent)
  .borderWidth(2)
  .borderColor(Color.Gray)
  .fontColor($r('app.color.reverse'))
}