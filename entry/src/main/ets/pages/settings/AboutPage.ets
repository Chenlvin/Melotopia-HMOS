import { CrashUtil, DialogUtil, FileUtil, LogUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { AppConstants } from "../../common/constants/AppConstants"
import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AppInfo, AppInfoClass } from "../../common/entities/AppInfo"
import SystemAppUtils from "../../common/utils/system/SystemAppUtils"
import { getAppInfo } from "../../api/chenlvinApi"
import { CommonSettingsCard } from "../../components/cards/SettingsCard"
import { WebPageParam } from "../../common/model/PageParams"
import { WarrantyDialog } from "../../components/dialog/WarrantyDialog"
import { PickerUtil } from "@pura/picker_utils"

@Component
export struct AboutPage {
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @StorageProp(StorageConstants.BUNDLE_NAME) bundleName: string = ''
  @State isCheckingUpdate: boolean = false
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack
  warrantyDialogController: CustomDialogController = new CustomDialogController({
    builder: WarrantyDialog(),
    autoCancel: false
  })

  private showLogDialog = () => {
    DialogUtil.showDialog({
      buttons: [
        {
          value: '查看错误日志',
          action: async () => {
            let content = await CrashUtil.getExceptionJson()
            DialogUtil.showConfirmDialog({
              title: 'Log',
              message: content
            })
          }
        },
        {
          value: '导出日志文件',
          fontColor: Color.Orange,
          action: () => {
            if(!CrashUtil.access()) {
              ToastUtil.showToast('未找到日志文件')
            } else {
              let path = CrashUtil.getFilePath()
              if (FileUtil.accessSync(path)) { //判断文件是否存在，存在然后导出
                PickerUtil.saveDocument({ newFileNames: ["Log.txt"] }).then((uris) => {
                  let file = FileUtil.openSync(uris[0])
                  FileUtil.copyFile(path, file.fd).then(() => {
                    FileUtil.close(file.fd)
                  })
                })
              } else {
                ToastUtil.showToast('未找到日志文件');
              }
            }
          }
        },
        {
          value: '清空日志信息',
          fontColor: Color.Red,
          action: () => {
            ToastUtil.showToast("已清理错误日志信息");
            CrashUtil.delete()
          }
        },
        {
          value: '取消',
          action: () => {}
        }
      ],
      title: $r('app.string.app_log'),
      message: '请选择操作'
    })
  }

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
                Text($r('app.string.version'))
                  .textStyle()
                if(this.appInfo.data.Version.currentVersionCode > AppConstants.VERSIONCODE) {
                  Text($r('app.string.new_version_found'))
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
                    ToastUtil.showToast(`${$r('app.string.checking_for_update')}...`)
                    await getAppInfo()
                  } catch (e) {
                    ToastUtil.showToast($r('app.string.error_occurred') + ': ' + e.message)
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
          if(this.bundleName !== AppConstants.BUNDLE_NAME_AG) {
            ListItem() {
              CommonSettingsCard({
                title: 'GitHub',
                action: () => {
                  SystemAppUtils.openInBrowser('https://github.com/Chenlvin/Melotopia-HMOS')
                }
              })
            }
          }
          ListItem() {
            CommonSettingsCard({
              title: $r('app.string.privacy_policy'),
              action: () => {
                let param: WebPageParam = {
                  title: $r('app.string.privacy_policy'), url: 'https://docs.chenlvin.cc/melotopia/#/privacy'
                }
                this.pushWebPage(param)
              }
            })
          }
          ListItem() {
            CommonSettingsCard({
              title: $r('app.string.app_log'),
              action: this.showLogDialog
            })
          }
          ListItem() {
            CommonSettingsCard({
              title: $r('app.string.sponsor'),
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
      title: $r('app.string.new_version_found'),
      message: `Version ${AppConstants.VERSION} → ${this.appInfo.data.Version.currentVersion}`,
      primaryButton: $r('app.string.close'),
      secondaryButton: {
        value: $r('app.string.download'),
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
}