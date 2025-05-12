import { CrashUtil, DialogUtil, LogUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AppInfo, AppInfoClass } from "../../common/entities/AppInfo"
import SystemAppUtils from "../../common/utils/system/SystemAppUtils"
import { getAppInfo } from "../../api/chenlvinApi"
import { CommonSettingsCard } from "../../components/cards/SettingsCard"
import { WebPageParam } from "../../common/model/PageParams"
import { WarrantyDialog } from "../../components/dialog/WarrantyDialog"

@Component
export struct AboutPage {
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @State isCheckingUpdate: boolean = false
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  build() {
    NavDestination() {
      List({ space: 10 }) {
        ListItem() {
          Column({ space: 20 }) {
            Image($r('app.media.appIcon'))
              .borderRadius(Constants.RADIUS_CARD)
              .width(80)
              .aspectRatio(1)
              .gesture(
                TapGesture({
                  fingers: 1,
                  count: 5
                }).onAction(() => {
                  this.settingsPageInfos.pushPathByName('DebugPage', null)
                })
              )

            Text('Melotopia')
              .fontWeight(Constants.FONT_WEIGHT_BOLD)
              .fontSize(Constants.FONT_SIZE_TITLE)
              .fontColor($r('app.color.reverse'))
          }
          .width('100%')
        }
        .padding({ bottom: Constants.PADDING_EDGE_TEXT })

        ListItem() {
          Button() {
            Row() {
              Row({ space: 10 }) {
                Text('应用版本')
                  .textStyle()
                if(this.appInfo.data.Version.currentVersionCode > AppConstants.VERSIONCODE) {
                  Text('发现新版本')
                    .fontWeight(FontWeight.Medium)
                    .fontSize(12)
                    .fontColor($r('app.color.app_red'))
                }
                if(this.isCheckingUpdate) {
                  LoadingProgress().width(20)
                }
              }
              .layoutWeight(1)
              Text(AppConstants.VERSION + ' ' + AppConstants.VER_DESC)
                .textStyle()
            }
            .height(Constants.HEIGHT_SETTINGS_ITEM)
            .width('100%')
            .justifyContent(FlexAlign.SpaceAround)
            .onClick(async () => {
              if(this.appInfo.data.Version.currentVersionCode > AppConstants.VERSIONCODE) {
                this.handleUpdate()
              } else {
                if(!this.isCheckingUpdate) {
                  this.isCheckingUpdate = true
                  try {
                    ToastUtil.showToast('正在检查更新...')
                    await getAppInfo()
                  } catch (e) {
                    ToastUtil.showToast('检查更新失败: ' + e.message)
                    LogUtil.error('Get AppInfo Error: ' + e.message + '\nStack: ' + e.stack)
                  } finally {
                    setTimeout(() => {
                      this.isCheckingUpdate = false
                    }, 500)
                  }
                }
              }
            })
          }
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
        }
        .itemStyle()

        ListItemGroup() {
          ListItem() {
            CommonSettingsCard({
              title: '隐私政策',
              action: () => {
                let param: WebPageParam = {
                  title: '隐私政策', url: 'https://docs.chenlvin.cc/melotopia/#/privacy'
                }
                this.pushWebPage(param)
              }
            })
          }
          ListItem() {
            CommonSettingsCard({
              title: '导出日志',
              action: () => {
                ToastUtil.showToast("导出日志: 我的手机/Download/Melotopia");
                setTimeout(() => {
                  CrashUtil.onExportErrorLog()
                }, 100)
              }
            })
          }
          ListItem() {
            CommonSettingsCard({
              title: '捐赠',
              action: () => {
                this.settingsPageInfos.pushPathByName('DonatePage', null)
              }
            })
          }
        }
        .itemStyle()
        .divider({ strokeWidth: 0.1, startMargin: 10, endMargin: 10, color: Color.Gray })
      }
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
      .padding(Constants.PADDING_EDGE_DEFAULT)
    }
    .title($r('app.string.About'))
    .backgroundColor($r('app.color.background'))
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }

  private pushWebPage(param: WebPageParam) {
    if(this.settingsPageInfos.size() < 2) {
      this.settingsPageInfos.pushPathByName('WebPage', param)
    } else {
      this.settingsPageInfos.replacePathByName('WebPage', param)
    }
  }

  private handleUpdate() {
    DialogUtil.showPrimaryDialog({
      title: '发现新版本',
      message: `Version ${AppConstants.VERSION} → ${this.appInfo.data.Version.currentVersion}`,
      primaryButton: "关闭",
      secondaryButton: {
        value: '前往下载',
        action: async () => {
          SystemAppUtils.openInBrowser(this.appInfo.data.Version.downloadUrl)
        }
      }
    })
  }
}

@Extend(Text) function textStyle() {
  .fontSize(16)
  .fontWeight(Constants.FONT_WEIGHT_BOLD)
  .fontColor($r('app.color.reverse'))
}