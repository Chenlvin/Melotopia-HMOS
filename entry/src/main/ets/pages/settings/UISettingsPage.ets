import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { changeSettings } from "../../common/functions/app/settings"
import { ToggleSettingItem } from "../../components/settings/SettingsItem"

@Component
export struct UISettingsPage {
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack
  @StorageProp(StorageConstants.MINI_BAR_BLUR) miniBarBlur: boolean = true
  @StorageProp(StorageConstants.NEW_LYRIC_EFFECT) newLyricEffect: boolean = true
  @StorageProp(StorageConstants.SHOW_ANNOUNCEMENT) showAnnouncement: boolean = true
  build() {
    NavDestination() {
      List({ space: 10 }) {
        ListItem() {
          ToggleSettingItem({
            name: '展示应用公告',
            onaction: () => { changeSettings(StorageConstants.SHOW_ANNOUNCEMENT, true) },
            offaction: () => { changeSettings(StorageConstants.SHOW_ANNOUNCEMENT, false) },
            value: this.showAnnouncement
          })
        }
        .itemStyle()

        ListItem() {
          ToggleSettingItem({
            name: '底部播放器模糊',
            onaction: () => {
              changeSettings(StorageConstants.MINI_BAR_BLUR, true)
              ToastUtil.showToast('开启此选项可能会增加设备功耗' )
            },
            offaction: () => { changeSettings(StorageConstants.MINI_BAR_BLUR, false) },
            value: this.miniBarBlur
          })
        }
        .itemStyle()

        ListItem() {
          ToggleSettingItem({
            name: '增强歌词效果（实验）',
            onaction: () => {
              changeSettings(StorageConstants.NEW_LYRIC_EFFECT, true)
              ToastUtil.showToast('开启此选项可能会增加设备功耗' )
            },
            offaction: () => { changeSettings(StorageConstants.NEW_LYRIC_EFFECT, false) },
            value: this.newLyricEffect
          })
        }
        .itemStyle()
      }
      .scrollBar(BarState.Off)
      .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title($r('app.string.SET_UI'))
    .backgroundColor($r('app.color.background'))
  }
}

@Extend(ListItem) function itemStyle() {
  .height(60)
  .backgroundColor($r('app.color.main'))
  .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  .borderRadius(Constants.RADIUS_CARD)
}