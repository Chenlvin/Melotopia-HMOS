import Constants from "../../common/constants/Constants"
import { DownloadItem } from "../../common/entities/local/Download"
import { LazyData } from "@pie/lazy-data"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { getArtists } from "../../common/functions/common/convert"
import DownloadUtils from "../../common/utils/file/DownloadUtils"

@Component
export struct DownloadListSheet {

  @StorageProp(StorageConstants.DOWNLOAD_QUEUE) downloadQueue: DownloadItem[] = []
  @StorageProp(StorageConstants.IS_DOWNLOADING) isDownloading: boolean = false
  @StorageProp(StorageConstants.IS_DOWNLOAD_PAUSED) isDownloadPaused: boolean = false
  @StorageProp(StorageConstants.DOWNLOADING_PROGRESS) progress: string = '0'
  @State dataSource: LazyData<DownloadItem> = new LazyData()

  private deleteItem(index: number) {
    DownloadUtils.deleteByIndex(index)
    this.dataSource.deleteData(index)
    this.dataSource.notifyDataReload()
  }

  aboutToAppear(): void {
    this.dataSource.setData(this.downloadQueue)
  }

  build() {
    Column() {
      Row() {
        Text() {
          Span('正在下载')
          Span(` (${this.downloadQueue.length})`)
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontColor(Color.Gray)
        }
        .fontColor($r('app.color.reverse'))
        .fontWeight(Constants.FONT_WEIGHT_BOLD)
        .fontSize(Constants.FONT_SIZE_TITLE)
        .layoutWeight(1)
        .padding(Constants.PADDING_EDGE_DEFAULT)

        this.ActionButton()

      }

      List({ space: 5 }) {
        ForEach(this.downloadQueue, (item: DownloadItem, index) => {
          this.DownloadItemCard(item, index)
        })
      }
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backToTop(true)
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder DownloadItemCard(item: DownloadItem, index: number) {
    Row() {
      Column() {
        Text(`${item.song.name} - ${getArtists(item.song.artists)}`)
          .textStyle(Constants.FONT_SIZE_COMMON)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .fontColor(DownloadUtils.getCurrentIndex() === index && this.isDownloading ? $r('app.color.app_red') : $r('app.color.reverse'))
        Text(DownloadUtils.getCurrentIndex() === index && this.isDownloading
          ? `正在下载: ${this.progress}%`
          : `${item.downloadItem.level}`)
          .textStyle(Constants.FONT_SIZE_COMMON)
          .fontColor(Color.Gray)
      }
      .layoutWeight(1)

      Image($r('app.media.ic_public_cancel')).width(20).fillColor(Color.Gray)
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
        .visibility(DownloadUtils.getCurrentIndex() === index && this.isDownloading ? Visibility.None : Visibility.Visible)
        .onClick(() => {
          this.deleteItem(index)
        })
    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
  }

  @Builder ActionButton() {
    Button() {
      Text('开始下载')
        .fontColor($r('app.color.reverse'))
    }
    .borderColor($r('app.color.reverse'))
    .backgroundColor(Color.Transparent)
    .padding(5)
    .visibility(!this.isDownloading ? Visibility.Visible : Visibility.None)
    .onClick(() => {
      DownloadUtils.startTask(0)
    })
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .width('100%')
  .textAlign(TextAlign.Start)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}