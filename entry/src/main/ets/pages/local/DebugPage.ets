import { StorageConstants } from "../../common/constants/StorageConstants";
import { User, User_INITIAL } from "../../common/entities/User";
import { JSON } from "@kit.ArkTS";
import Constants from "../../common/constants/Constants";
import { resourceManager } from "@kit.LocalizationKit";
import { AppConstants } from "../../common/constants/AppConstants";
import PreferencesUtils from "../../common/utils/data/PreferencesUtils";
import { FloatLyric_INITIAL, LyricStyle_INITIAL } from "../../common/model/Settings";
import { bundle } from "@kit.AbilityKit";

@Component
export struct DebugPage {
  @StorageProp(StorageConstants.COOKIE) cookie: string = ''
  @StorageProp(StorageConstants.USER) user: User = User_INITIAL
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @StorageProp(StorageConstants.BUNDLE_NAME) bundleName: string = ''
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) widBp: string = 'sm'
  @StorageProp(StorageConstants.BREAKPOINT_HEIGHT) heightBp: string = 'sm'
  @State apiUrl: string = ''
  @State result: string = ''

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          // Button('Clean RelationalStore').onClick(() => {
          //   RelationalStoreUtils.clearAllData()
          //   promptAction.showToast({ message: 'RelationalStore Cleaned' })
          // })
          Text(`Bundle: ${this.bundleName}`)
            .textStyle()
          Text(`APP Version: ${AppConstants.VERSION} ${AppConstants.VER_DESC}\nVersion Code: ${AppConstants.VERSIONCODE}`)
            .textStyle()
          Text(`deviceType: ${this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_PHONE ? 'Phone' :
              this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_TABLET ? 'Tablet' :
              this.deviceType == resourceManager.DeviceType.DEVICE_TYPE_2IN1 ? '2in1' : 'Unknown'} `)
            .textStyle()
          Text(`Width Breakpoint: ${this.widBp}`)
            .textStyle()
          Text(`Height Breakpoint: ${this.heightBp}`)
            .textStyle()
          // Button('Reset Lyric Persistent Settings')
          //   .onClick(() => {
          //     PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.FLOAT_LYRIC_STYLE, FloatLyricItem)
          //     PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.LYRIC_STYLE, LyricStyleItem)
          //   })
          Row({ space: 10 }) {
            TextInput()
              .onChange((text) => { this.apiUrl = text })
              .layoutWeight(1)
            Button('request')
              .onClick(async () => {
                await this.request()
              })
          }
          Text('Result: ' + this.result)
            .textStyle()
          Text(`current user: ${JSON.stringify(this.user, null, 2).replace(/\n/g, '\n')}`)
            .textStyle()
          Text(`cookie: \n${this.cookie}`)
            .textStyle()
        }
        .padding(Constants.PADDING_EDGE_DEFAULT)
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .title('Debug')
  }

  async request() {
    // const rootUrl = await getApiUrl()
    // const url = rootUrl + this.apiUrl
    // try {
    //   const request = new HttpRequest(url)
    //   const data = await request.RequestInStream()
    //   if(data.responseCode == 200) {
    //     ToastUtil.showToast('200 OK')
    //     this.result = JSON.stringify(data.result, null, 2).replace(/\n/g, '\n')
    //   }
    // } catch (e) {
    //   ToastUtil.showToast('Request Error:\n' + e.message)
    // }
  }
}

@Extend(Text) function textStyle() {
  .copyOption(CopyOptions.LocalDevice)
  .textSelectable(TextSelectableMode.SELECTABLE_UNFOCUSABLE)
  .width('100%')
}