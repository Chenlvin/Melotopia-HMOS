import { ToastUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { Api, Api_INITIAL } from "../../common/model/Api"
import { checkValidUrl } from "../../common/functions/common/get"
import PreferencesUtils from "../../common/utils/data/PreferencesUtils"
import { ExplainButton } from "../../components/buttons/ExplainButton"

/**
 * 自定义API服务器地址
 * Sheet
 */
@Component
export struct ApiSetPage {
  @StorageLink(StorageConstants.IS_CUSTOM_COOKIE) isCustomCookie: boolean = false
  @StorageProp(StorageConstants.CUSTOM_COOKIE) customCookie: string = ''
  @StorageProp(StorageConstants.API_URL) customApiUrl: string = ''
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.API_SETTINGS) apiSettings: Api = Api_INITIAL
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State selected: number = 0

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          Text('用户可以搭建私有云\n设置连接信息后可获取云端歌曲')
            .textAlign(TextAlign.Center)
          Text() {
            Span(`配置连通性: `)
            Span(`${this.validApiUrl ? '正常' : '不可用'}`)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.validApiUrl ? Color.Green : $r('app.color.app_red'))
          }
          .width('100%')
          .textAlign(TextAlign.Center)
          .fontColor($r('app.color.reverse'))
          .fontSize(Constants.FONT_SIZE_COMMON)
          .padding(Constants.PADDING_EDGE_DEFAULT)
          this.SetApiUrl()
          if(this.validApiUrl) {
            this.SetCookie()
          }
        }
        .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, bottom: px2vp(this.bottomRectHeight) + Constants.PADDING_EDGE_TEXT })
        .width('100%')
        .constraintSize({
          minWidth: 200,
          maxWidth: 600
        })
      }
      .width('100%')
      .scrollBar(BarState.Off)
    }
    .backgroundColor($r('app.color.background'))
    .title($r('app.string.SET_CLOUDSERVICE'))
  }

  @Builder SetApiUrl() {
    Column({ space: 10 }) {

      Text() {
        Span('当前设置: ')
        Span(this.customApiUrl)
      }

      Row({ space: 10 }) {
        Text('主机').LeftText()
        TextInput({ text: this.apiSettings.domain })
          .layoutWeight(1)
          .onChange((text) => this.apiSettings.domain = text)
          .borderRadius(Constants.RADIUS_IMG)
      }

      Row({ space: 10 }) {
        Text('端口').LeftText()
        TextInput({ text: this.apiSettings.port.toString() })
          .layoutWeight(1)
          .type(InputType.Number)
          .onChange((text) => this.apiSettings.port = Number(text))
          .borderRadius(Constants.RADIUS_IMG)
      }

      Row({ space: 10 }) {
        Text('请求').LeftText()
        Row() {
          Text('HTTP')
            .padding({ right: 5 })
          Radio({ value: 'http', group: 'HTTP' })
            .checked(this.selected == 0)
            .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
            .onClick(() => { this.apiSettings.https = false })
            .padding({ right: 30 })
          Text('HTTPS')
            .padding({ right: 5 })
          Radio({ value: 'https', group: 'HTTP' })
            .checked(this.selected == 1)
            .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
            .onClick(() => { this.apiSettings.https = true })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row({ space: 10 }) {
        Text('路径').LeftText()
        TextInput({ text: this.apiSettings.path,  })
          .layoutWeight(1)
          .onChange((text) => this.apiSettings.path = text)
          .borderRadius(Constants.RADIUS_IMG)
      }

      Row({ space: 10 }) {
        Text('用户').LeftText()
        TextInput({ text: this.apiSettings.user,  })
          .layoutWeight(1)
          .onChange((text) => this.apiSettings.user = text)
          .borderRadius(Constants.RADIUS_IMG)
      }

      Row({ space: 10 }) {
        Text('密码').LeftText()
        TextInput({ text: this.apiSettings.password,  })
          .layoutWeight(1)
          .onChange((text) => this.apiSettings.password = text)
          .borderRadius(Constants.RADIUS_IMG)
      }

      Button('保存配置')
        .setButton()
        .onClick(() => {
          this.saveApiSettings()
        })
    }
    .itemStyle()
  }

  @Builder SetCookie() {
    Column({ space: 10 }) {
      Row() {
        Row({ space: 5 }) {
          Text('(高级) 手动设置Cookie').LeftText()
          ExplainButton({ title: '手动设置Cookie',
            msg: '注意: 若您使用应用内登录，请勿开启此选项\n\n' +
              '设置后每次API请求都将使用该Cookie, 包括登录、用户信息等获取, 重启或刷新登录后生效\n\n'
          })
        }
        Toggle({ type: ToggleType.Switch, isOn: this.isCustomCookie })
          .height(24)
          .width(48)
          .selectedColor($r('app.color.app_red'))
          .onChange((isOn) => {
            animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
              this.toggleCustomCookie(isOn)
            })
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if(this.isCustomCookie) {
        Column({ space: 10 }) {
          TextArea({ text: this.customCookie })
            .width('100%')
            .onChange((text) => this.customCookie = text)
            .borderRadius(Constants.RADIUS_IMG)
            .height(150)
            .textAlign(TextAlign.Start)
          Button('保存Cookie')
            .setButton()
            .onClick(() => {
              this.setCustomCookie()
            })
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
      }
    }
    .itemStyle()
  }

  toggleCustomCookie(isOn: boolean) {
    this.isCustomCookie = isOn
    AppStorage.setOrCreate(StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.IS_CUSTOM_COOKIE, this.isCustomCookie)
  }

  saveApiSettings() {
    const https = this.apiSettings.https ? 'https://' : 'http://'
    const API_URL = https + this.apiSettings.domain + ':' + this.apiSettings.port + this.apiSettings.path
    AppStorage.setOrCreate(StorageConstants.API_SETTINGS,this.apiSettings)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.API_SETTINGS, this.apiSettings)
    AppStorage.setOrCreate(StorageConstants.API_URL, API_URL)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF, StorageConstants.API_URL, API_URL)
    ToastUtil.showToast('配置已保存, 正在检查服务是否可用...')
    setTimeout(() => {
      checkValidUrl()
    }, 500)
  }

  setCustomCookie() {
    let cookie = this.customCookie.trim()
    if (cookie.endsWith(';')) {
      cookie = cookie.slice(0, cookie.length - 1)
    }
    if (!cookie.endsWith('; OS=pc')) {
      cookie += '; OS=pc'
    }
    AppStorage.setOrCreate(StorageConstants.CUSTOM_COOKIE, cookie)
    PreferencesUtils.putPreferenceValue(StorageConstants.SET_PERF ,StorageConstants.CUSTOM_COOKIE, cookie)
    ToastUtil.showToast('配置已保存')
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }
}

@Extend(Text) function LeftText() {
  .textAlign(TextAlign.Start)
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontWeight(FontWeight.Bold)
}

@Extend(Button) function setButton() {
  .fontSize(Constants.FONT_SIZE_COMMON)
  .fontColor($r('app.color.app_red'))
  .borderColor($r('app.color.app_red'))
  .backgroundColor(Color.Transparent)
  .borderWidth(1)
  .width(150)
  .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
}