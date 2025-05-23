import Constants from "../../common/constants/Constants"
import { PlayConstants } from "../../common/constants/PlayConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { QualityType } from "../../common/entities/Song"
import { PlaySettingsPageMap } from "../../common/model/PageMap"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import AVPlayerUtils from "../../common/utils/play/AVPlayerUtils"
import { CommonSettingsCard } from "../../components/cards/SettingsCard"
import { LyricTranslate, SetLyricStyle } from "../../components/settings/LyricSettings"
import { resourceManager } from "@kit.LocalizationKit"

@Component
export struct PlaySettingsPage {
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

  build() {
    NavDestination() {
      PlaySettings({
        floatLyricAction: () => {
          this.settingsPageInfos.pushPathByName('FloatLyricPage', null)
        }
      })
    }
    .title($r('app.string.SET_PLAYANDLYRIC'))
    .backgroundColor($r('app.color.background'))
  }
}

@Component
export struct PlaySettingSinglePage {
  @Provide('playSettingsPageInfos') playSettingsPageInfos: NavPathStack = new NavPathStack()
  @StorageLink(StorageConstants.IS_PLAYER_SHOW) isPlayerShow: boolean = false
  private flag: number = 0
  aboutToAppear(): void {
    if(this.isPlayerShow) {
      this.isPlayerShow = false
      this.flag = 1
    }
  }

  aboutToDisappear(): void {
    if(this.flag) this.isPlayerShow = true
  }

  build() {
    Navigation(this.playSettingsPageInfos) {
      Column() {
        Text($r('app.string.SET_PLAYANDLYRIC'))
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .padding({ left: Constants.PADDING_EDGE_TEXT })
          .height(56)
        PlaySettings({
          floatLyricAction: () => {
            this.playSettingsPageInfos.pushPathByName('FloatLyricPage', null)
          }
        })
      }
    }
    .backgroundColor($r('app.color.background'))
    .hideTitleBar(true)
    .navDestination(PlaySettingsPageMap)
    .hideBackButton(true)
  }
}

@Component
struct PlaySettings {
  @StorageLink(StorageConstants.PLAY_QUALITY) playQuality: QualityType = "standard"
  @StorageLink(StorageConstants.MIX_WITH_OTHERS) @Watch('toggleMixWithOthers') isActived: boolean = false
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType | null = null
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State qualitySelected: number | undefined = 0
  floatLyricAction: () => void = () => {}

  async aboutToAppear(): Promise<void> {
    this.qualitySelected = await AppStorage.get(StorageConstants.PLAY_QUALITY)
  }

  toggleMixWithOthers() {
    PreferencesUtils.putPreferenceValue(
      StorageConstants.SET_PERF,
      StorageConstants.MIX_WITH_OTHERS,
      this.isActived
    )
  }

  build() {
    List({ space: 10 }) {
      ListItem() {
        Row() {
          Text($r('app.string.play_quality'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(FontWeight.Bold)
          Select([{ value: $r('app.string.standard') }, { value: $r('app.string.high') }, { value: $r('app.string.exhigh') }, { value: $r('app.string.lossless') }])
            .selectedOptionFontColor($r('app.color.app_red'))
            .selected(this.qualitySelected)
            .value(this.qualitySelected ? PlayConstants.QUALITY_NAME[this.qualitySelected] : $r('app.string.standard'))
            .constraintSize({
              minHeight: 0,
              maxHeight: '100%'
            })
            .height(Constants.HEIGHT_SELECT)
            .onSelect((index: number) => {
              AppStorage.setOrCreate(StorageConstants.PLAY_QUALITY,index)
              PreferencesUtils.putPreferenceValue('Settings', StorageConstants.PLAY_QUALITY, index)
            })
        }
        .height(Constants.HEIGHT_SETTINGS_ITEM)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .itemStyle()

      ListItem() {
        Row() {
          Text($r('app.string.mix_with_others'))
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(FontWeight.Bold)
          Toggle({ type: ToggleType.Switch, isOn: this.isActived })
            .height(24)
            .width(48)
            .onChange((isOn) => {
              this.isActived = isOn
              AVPlayerUtils.setAudioSession()
            })
            .selectedColor($r('app.color.app_red'))
        }
        .height(Constants.HEIGHT_SETTINGS_ITEM)
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .itemStyle()

      if(this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_PHONE ||
      this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_TABLET) {
        ListItem() {
          CommonSettingsCard({
            title: $r('app.string.float_lyric'),
            action: this.floatLyricAction
          })
        }
        .itemStyle()
      }

      ListItem() {
        LyricTranslate()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .itemStyle()

      ListItem() {
        SetLyricStyle()
      }
      .itemStyle()

      ListItem()
        .height(px2vp(this.bottomRectHeight))
    }
    .scrollBar(BarState.Off)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .height('100%')
    .width('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}

@Extend(ListItem) function itemStyle() {
  .backgroundColor($r('app.color.main'))
  .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
  .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  .borderRadius(Constants.RADIUS_CARD)
}