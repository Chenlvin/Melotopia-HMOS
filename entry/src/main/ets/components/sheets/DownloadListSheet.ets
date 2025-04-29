import Constants from "../../common/constants/Constants"
import { DownloadItem } from "../../common/entities/local/Download"
import { LazyData } from "@pie/lazy-data"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { getArtists } from "../../common/functions/common/convert"
import DownloadUtils from "../../common/utils/file/DownloadUtils"
import { DialogUtil } from "@pura/harmony-utils"

@Component
export struct DownloadListSheet {

  @StorageProp(StorageConstants.DOWNLOAD_QUEUE) @Watch('updateDataSource') downloadQueue: DownloadItem[] = []
  @StorageProp(StorageConstants.IS_DOWNLOADING) isDownloading: boolean = false
  @StorageProp(StorageConstants.IS_DOWNLOAD_PAUSED) isDownloadPaused: boolean = false
  @StorageProp(StorageConstants.DOWNLOADING_PROGRESS) progress: string = '0'
  @State dataSource: LazyData<DownloadItem> = new LazyData()

  private deleteItem(index: number) {
    DownloadUtils.deleteByIndex(index)
    // this.dataSource.deleteData(index)
    // this.dataSource.notifyDataReload()
  }

  updateDataSource() {
    this.dataSource.setData(this.downloadQueue)
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
        LazyForEach(this.dataSource, (item: DownloadItem, index) => {
          this.DownloadItemCard(item, index)
        }, (item: DownloadItem, index) => item.song.name + index)
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
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
    Row({ space: 10 }) {
      Button() {
        Text('下载')
          .fontColor($r('app.color.reverse'))
      }
      .borderRadius(1)
      .borderColor($r('app.color.reverse'))
      .backgroundColor(Color.Transparent)
      .padding(5)
      .visibility(!this.isDownloading ? Visibility.Visible : Visibility.None)
      .onClick(() => {
        DownloadUtils.startTask(0)
      })

      Button() {
        Text('清空')
          .fontColor($r('app.color.reverse'))
      }
      .borderRadius(1)
      .borderColor($r('app.color.reverse'))
      .backgroundColor(Color.Transparent)
      .padding(5)
      .onClick(() => {
        DialogUtil.showPrimaryDialog({
          title: '确认',
          message: '清空下载列表',
          primaryButton: "取消",
          secondaryButton: {
            value: '清空',
            fontColor: Color.Red,
            action: () => {
              DownloadUtils.clearTask()
              this.dataSource.setData([])
              this.dataSource.notifyDataReload()
            }
          }
        })
      })
    }
    .layoutWeight(1)
    .width('100%')
    .justifyContent(FlexAlign.End)
  }
}

@Extend(Text) function textStyle(size: number) {
  .fontSize(size)
  .width('100%')
  .textAlign(TextAlign.Start)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}