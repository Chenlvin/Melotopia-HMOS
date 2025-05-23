import { DialogUtil, ToastUtil } from "@pura/harmony-utils"
import { getLoginStatus, logOut } from "../../api/loginApi"
import Constants from "../constants/Constants"
import { StorageConstants } from "../constants/StorageConstants"
import { User, User_INITIAL } from "../entities/User"
import { initUserInfo } from "../functions/app/appInit"
import { SettingsPage } from "../../pages/settings/SettingsPage"
import { CircleImageButton } from "../../components/buttons/CircleButton"

@Component
export struct Me {
  @StorageProp(StorageConstants.IS_LOGGED) isLogged: boolean = false
  @StorageProp(StorageConstants.USER) user: User = User_INITIAL
  @StorageProp(StorageConstants.VALID_API_URL) isValidAPI: boolean = true
  @StorageProp(StorageConstants.VALID_COOKIE) isValidCookie: boolean = true
  @StorageProp(StorageConstants.COOKIE) cookie: string = ''
  @StorageProp(StorageConstants.APP_LOADING) appLoading: boolean = true
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @State isRefreshing: boolean = false
  @Prop breakpoint: string = 'sm'
  @StorageLink('isShowSettings') isShowSettings: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack

  private settingsSheetOptions: SheetOptions = {
    preferType: SheetType.CENTER,
    height: SheetSize.LARGE,
    dragBar: false,
    showClose: false,
    scrollSizeMode: ScrollSizeMode.FOLLOW_DETENT,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.isShowSettings = false }
  }

  async aboutToAppear(): Promise<void> {
    if(this.isValidAPI && this.cookie && !this.isLogged) {
      this.appLoading = true
      await getLoginStatus(this.cookie)
      this.appLoading = false
    }
  }

  private async handleRefresh() {
    this.isRefreshing = true
    ToastUtil.showToast('正在刷新登录状态')
    try {
      await initUserInfo()
    } finally {
      this.isRefreshing = false
    }
  }

  build() {
    Scroll() {
      Column({ space: 10 }) {
        Column() {
          if (this.isLogged) {
            Row({ space: 20 }) {
              CircleImageButton({ imgUrl: this.user.data.profile.avatarUrl + '?param=256y256', wid: 64 })
              Text(this.user.data.profile.nickname).textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
              Text(this.user.data.account.vipType == 110 ? 'SVIP' : 'VIP')
                .fontColor(Color.White)
                .fontSize(12)
                .padding({ left: 10, right: 10, bottom: 5, top: 5 })
                .backgroundColor(this.user.data.account.vipType === 110 ? Color.Orange : $r('app.color.app_red'))
                .borderRadius(Constants.RADIUS_CARD)
                .visibility(this.user.data.account.vipType === 0 ? Visibility.None : Visibility.Visible)
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .padding({ bottom: 10 })
          } else if(this.appLoading) {
            LoadingProgress().width(40)
          } else if(this.isValidAPI) {
            Row({ space: 20 }) {
              CircleImageButton({ imgUrl: $r('app.media.ic_user_portrait'), wid: 64 })
              Text('未登录').textStyle(Constants.FONT_SIZE_TITLE).fontWeight(FontWeight.Bold)
              this.RefreshButton()
            }
            .justifyContent(FlexAlign.Center)
            .width('100%')
            .padding({ bottom: 10 })
          }
        }
        .height( this.isValidAPI ? 80 : 0)

        Column() {
          this.ItemCard($r('app.media.ic_public_settings_filled'), $r('app.string.settings'), () => {
            this.isShowSettings = true
          })
        }
        .itemColumnStyle()

        Column() {
          this.ItemCard($r('app.media.ic_public_folder_filled'), $r('app.string.LocalSongs'), () => {
            if(this.pageInfos.size() === 0) {
              this.pageInfos.pushPathByName('LocalSongPage', null, this.breakpoint === 'lg' ? false : true)
            } else {
              this.pageInfos.replacePath({ name: 'LocalSongPage', param: null }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
            }
          })
        }
        .itemColumnStyle()

        Column().padding(30)

        if(this.isValidAPI && !this.appLoading) {
          if(this.isLogged) {
            this.LoginButton($r('app.color.app_red'), $r('app.string.Logout'), () => {
              this.LogOut()
            })
          } else {
            this.LoginButton(Color.Blue, $r('app.string.Login'), () => {
              this.pageInfos.pushPathByName('LoginPage', null, this.breakpoint === 'lg' && this.pageInfos.size() === 0 ? false : true)
            })
          }
        }
      }
      .width('100%')
      .height('auto')
      .constraintSize({
        minWidth: 200,
        maxWidth: 500
      })
      .backgroundColor($r('app.color.background'))
      .padding({ left: 20, right: 20, bottom: px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI + 64 })
      .bindSheet(this.isShowSettings, this.Settings(), this.settingsSheetOptions)
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .scrollBar(BarState.Off)
  }

  @Builder ItemCard(icon: ResourceStr | string, text: string | ResourceStr, action: () => void) {
    Button() {
      Row({ space: 10 }) {
        Image(icon).iconStyle()
        Text(text).textStyle(16).fontWeight(FontWeight.Medium).textAlign(TextAlign.Start).layoutWeight(1)
        Image($r('app.media.ic_public_arrow_right')).iconStyle()
      }
    }
    .backgroundColor(Color.Transparent)
    .width('100%')
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }

  @Builder LoginButton(color: Color | string | ResourceStr, text: string | ResourceStr, action: () => void) {
    Button() {
      Row({ space: 10 }) {
        Text(text)
          .textStyle(Constants.FONT_SIZE_COMMON + 2)
          .textAlign(TextAlign.Center)
          .fontColor(Color.White)
      }
    }
    .backgroundColor(color)
    .width('100%')
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .onClick(action)
  }

  @Builder RefreshButton() {
    if(this.isRefreshing) {
      LoadingProgress().width(Constants.FONT_SIZE_COMMON).aspectRatio(1)
    } else {
      Image($r('app.media.ic_public_refresh'))
        .width(Constants.FONT_SIZE_COMMON)
        .aspectRatio(1)
        .fillColor($r('app.color.reverse'))
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .onClick(() => {
          this.handleRefresh()
        })
    }
  }

  @Builder Settings() {
    SettingsPage()
  }

  private LogOut() {
    DialogUtil.showPrimaryDialog({
      title: '确认',
      message: '是否退出登录?',
      primaryButton: "取消",
      secondaryButton: {
        value: '确认',
        fontColor: Color.Red,
        action: async () => {
          let result = await logOut()
          if(result) {
            ToastUtil.showToast('成功退出登录')
          } else {
            ToastUtil.showToast('退出登录时出错')
          }
        }
      }
    })
  }
}

@Extend(Text) function textStyle(size: number = Constants.FONT_SIZE_COMMON) {
  .fontSize(size)
  .textAlign(TextAlign.Center)
  .fontColor($r('app.color.reverse'))
}

@Extend(Image) function iconStyle() {
  .width(Constants.SIZE_ICON_BUTTON_BAR)
  .fillColor(Color.Gray)
  .draggable(false)
}

@Extend(Column) function itemColumnStyle() {
  .backgroundColor($r('app.color.main'))
  .borderRadius(Constants.RADIUS_CARD)
  .width('100%')
  .padding(5)
}