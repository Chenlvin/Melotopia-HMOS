import { LazyData } from "@pie/lazy-data"
import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayListSong } from "../../common/entities/playlist/PlayListSongs"
import { AlbumItem } from "../../common/entities/song/Album"
import { Song } from "../../common/entities/song/Song"
import { getArtists } from "../../common/functions/common/convert"
import DownloadUtils from "../../common/utils/file/DownloadUtils"

@Component
export struct ListSelectSheet {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State selected: PlayListSong[] = []
  selectedIndex: number[] = []
  @Link isShow: boolean
  @State dataSource: LazyData<PlayListSong> = new LazyData()
  songs: PlayListSong[] = []

  aboutToAppear(): void {
    this.dataSource.setData(this.songs)
  }
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
            id: item.id,
            artists: item.ar,
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

      List({ space: Constants.PADDING_MEDIUM }) {
        ListItem().height(Constants.PADDING_EDGE_DEFAULT)
        LazyForEach(this.dataSource, (item: PlayListSong, index) => {
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
      .divider({ strokeWidth: 0.1, startMargin: 35, endMargin: 50, color: Color.Gray })
      .scrollBar(BarState.Off)
    }
  }

  @Builder Card(index: number, song: PlayListSong) {
    Row({ space: 5 }) {
      Text(`${index + 1}`)
        .fontSize(10)
        .fontColor(Color.Gray)
        .width(30)
        .textAlign(TextAlign.Center)
      Column({ space: 5 }) {
        Text(song.name)
          .textStyle(16)
        Text(getArtists(song.ar))
          .textStyle(12)
          .fontColor(Color.Gray)
      }
      .layoutWeight(1)
      Checkbox({ group: 'selectSongs' })
        .select(this.selectedIndex.includes(index))
        .padding({ right: 5 })
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .aspectRatio(1)
        .onChange((value) => {
          if(value) {
            this.selected.push(song)
            this.selectedIndex.push(index)
          } else {
            this.selected = this.selected.filter(item => item.id !== song.id)
            this.selectedIndex = this.selectedIndex.filter(item => item !== index)
          }
        })
    }
    .padding({ left: 5, right: 15 })
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .width('100%')
  .textAlign(TextAlign.Start)
}