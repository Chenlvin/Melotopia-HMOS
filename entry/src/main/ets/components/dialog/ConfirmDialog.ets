import Constants from "../../common/constants/Constants"

@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController
  title: string = ''
  message: string = ''
  cancelValue: string = '取消'
  confirmValue: string = '确认'
  cooldownInterval: number = 0
  @State cooldown: number = 6

  aboutToAppear(): void {
    this.cooldownInterval = setInterval(() => {
      if(this.cooldown > 0) this.cooldown -= 1
    }, 1000)
  }

  build() {
    Column() {
      Row() {
        Button(this.cancelValue)
          .clickButton()
          .onClick(() => { this.controller.close() })
      }
    }
  }
}

@Extend(Button) function clickButton() {
  .type(ButtonType.Normal)
  .borderRadius(Constants.RADIUS_BUTTON)
  .backgroundColor(Color.Transparent)
  .layoutWeight(1)
  .width('100%')
  .height(Constants.HEIGHT_TEXT_BUTTON)
}