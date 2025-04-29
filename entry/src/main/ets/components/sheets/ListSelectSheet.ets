import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AlbumItem } from "../../common/entities/song/Album"
import { SimpleSong, Song } from "../../common/entities/song/Song"
import { getArtists } from "../../common/functions/common/convert"
import DownloadUtils from "../../common/utils/file/DownloadUtils"

@Component
export struct ListSelectSheet {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State selected: SimpleSong[] = []
  @Link isShow: boolean
  songs: SimpleSong[] = []

  private handleDownload = () => {
    if(this.selected.length === 0) {
      ToastUtil.showToast('请先选择需要操作的内容')
      return
    }
    DialogUtil.showPrimaryDialog({
      title: '下载',
      message: `是否下载所选的 ${this.selected.length} 项内容`,
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        action: () => {
          this.isShow = false
          let temp: Song[] = this.selected.map((item): Song => ({
            id: item.songId,
            artists: item.artists,
            name: item.name,
            alias: [],
            album: AlbumItem,
            duration: 0,
            fee: 0
          }))

          DownloadUtils.addItem(temp, 3)
        }
      }
    })
  }

  build() {
    Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
      Row({ space: 15 }) {
        Text(`已选 ${this.selected.length} 项`)
          .textStyle(16)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .layoutWeight(1)

        Image($r('app.media.ic_public_download_filled'))
          .width(Constants.SIZE_ICON_BUTTON_BAR_SMALL)
          .aspectRatio(1)
          .onClick(this.handleDownload)
          .fillColor($r('app.color.reverse'))
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })

        // CheckboxGroup({ group: 'selectSongs' })
        //   .width(Constants.SIZE_ICON_BUTTON_BAR_SMALL)
        //   .aspectRatio(1)
      }
      .width('100%')
      .padding({
        top: Constants.PADDING_MEDIUM,
        left: Constants.PADDING_EDGE_TEXT,
        right: Constants.PADDING_EDGE_TEXT
      })

      List({ space: 10 }) {
        ListItem().height(Constants.PADDING_EDGE_DEFAULT)
        ForEach(this.songs.slice(0, 500), (item: SimpleSong, index) => {
          this.Card(index, item)
        })
        ListItem() {
          Text('没有更多了~')
            .fontSize(12)
            .fontColor(Color.Gray)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .padding({ bottom: px2vp(this.bottomRectHeight) })
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .divider({ strokeWidth: 0.1, startMargin: 35, endMargin: 20, color: Color.Gray })
      .scrollBar(BarState.Off)
    }
  }

  @Builder Card(index: number, simpleSong: SimpleSong) {
    Row({ space: 5 }) {
      Text(index.toString())
        .fontSize(10)
        .fontColor(Color.Gray)
        .width(30)
        .textAlign(TextAlign.Center)
      Column({ space: 5 }) {
        Text(simpleSong.name)
          .textStyle(16)
        Text(getArtists(simpleSong.artists))
          .textStyle(12)
          .fontColor(Color.Gray)
      }
      .layoutWeight(1)
      Checkbox({ group: 'selectSongs' })
        .padding({ right: 5 })
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .aspectRatio(1)
        .onChange((value) => {
          if(this.selected.length >= 50) {
            ToastUtil.showToast('最多选择50项')
            return
          }
          if(value) {
            this.selected.push(simpleSong)
          } else {
            this.selected = this.selected.filter(item => item.songId !== simpleSong.songId)
          }
        })
    }
    .padding({ left: 5 })
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .width('100%')
  .textAlign(TextAlign.Start)
}