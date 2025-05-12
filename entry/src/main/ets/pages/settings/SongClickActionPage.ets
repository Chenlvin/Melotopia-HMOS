import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { Song } from "../../common/entities/Song"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import VibratorUtils from "../../common/utils/system/VibratorUtils"
import { SongCard } from "../../components/cards/SongCard"


/**
 * 歌曲卡片点击操作
 * Sheet
 */
@Component
export struct SongClickActionPage {
  @StorageLink(StorageConstants.SONG_CLICK_ACTION) @Watch('changeActionType') clickAction: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isShowSheet: boolean = false
  @State egSong: Song = {
    id: -1,
    name: '歌曲名',
    artists: [{
      id: -1,
      name: '艺术家名'
    }],
    album: {
      id: 0,
      name: '',
      picUrl: '',
      artists: [],
      size: 0
    },
    duration: 0,
    alias: [],
    fee: 1
  }

  changeActionType() {
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.SONG_CLICK_ACTION, this.clickAction)
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 10 }) {
          Text('歌曲卡片样式')
            .titleStyle()
          Stack() {
            SongCard({
              picUrl: $r('app.media.ic_files_audio'),
              song: this.egSong
            })
            Button()
              .backgroundColor(Color.Transparent)
              .width('100%')
              .height(60)
              .type(ButtonType.Normal)
              .bindSheet(this.isShowSheet, this.EgSheet(), {
                preferType: SheetType.CENTER,
                height: '50%',
                dragBar: false,
                showClose: false,
                backgroundColor: Color.Transparent,
                blurStyle: BlurStyle.Regular,
                onDisappear: (() => { this.isShowSheet = false })
              })
              .gesture(
                LongPressGesture({
                  duration: 500
                }).onAction(() => {
                  VibratorUtils.startCount('sharp', 1, 100)
                  this.isShowSheet = true
                })
              )
              .onClick(async () => {
                if(this.clickAction == 0) {
                  this.isShowSheet = true
                } else if(this.clickAction == 1) {
                  ToastUtil.showToast('单曲播放')
                } else {
                  ToastUtil.showToast('随歌单一同播放',)
                }
              })
          }

          Text('设置卡片单击操作')
            .titleStyle()
          this.SettingItem(0, '优先弹出半模态界面')
          this.SettingItem(1, '直接播放（优先播放单曲）')
          this.SettingItem(2, '直接播放（优先随歌单播放）')

          Text('歌曲卡片操作说明')
            .titleStyle()

          Text() {
            Span('单击：支持设置对应操作' + '\n')
            Span('长按：弹出半模态界面')
          }
          .fontColor($r('app.color.reverse'))
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .width('100%')
          .textAlign(TextAlign.Start)
          .lineHeight(20)
        }
        .padding({
          left: 20,
          right: 20,
          bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT,
          top: Constants.PADDING_EDGE_DEFAULT
        })
        .width('100%')
        .height('auto')
        .justifyContent(FlexAlign.Start)
      }
      .height('100%')
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.Off)
    }
    .title($r('app.string.SET_SONGCARD'))
    .backgroundColor($r('app.color.background'))
  }

  @Builder SettingItem(index: number, text: string) {
    Row({ space: 10 }) {
      Radio({ value: `${index}` , group: 'clickAction' })
        .checked(this.clickAction == index)
        .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
        .onChange((isChecked) => {
          if(isChecked) {
            this.clickAction = index
          }
        })
      Text(text)
        .fontColor($r('app.color.reverse'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Medium)
        .width('100%')
        .textAlign(TextAlign.Start)
        .lineHeight(20)
    }
    .width('100%')
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .itemStyle()
  }

  @Builder EgSheet() {
    Column() {
      Text('半模态界面样例')
        .padding(Constants.PADDING_EDGE_TEXT)
        .width('100%')
        .textAlign(TextAlign.Center)
    }
    .width(200)
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }

}

@Extend(Text) function titleStyle() {
  .fontColor($r('app.color.reverse'))
    .fontSize(Constants.FONT_SIZE_COMMON)
    .fontWeight(FontWeight.Bold)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT })
    .width('100%')
}