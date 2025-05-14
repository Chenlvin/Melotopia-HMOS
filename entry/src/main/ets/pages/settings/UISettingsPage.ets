@Component
export struct UISettingsPage {
  @Consume('settingsPageInfos') settingsPageInfos: NavPathStack

  build() {
    NavDestination() {

    }
    .title($r('app.string.SET_UI'))
    .backgroundColor($r('app.color.background'))
  }
}