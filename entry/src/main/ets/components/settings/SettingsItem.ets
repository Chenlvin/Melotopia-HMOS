import Constants from '../../common/constants/Constants'

@Component export struct ToggleSettingItem {
  name: string = ''
  onaction = () => {}
  offaction = () => {}
  action = () => {}
  @Link value: boolean

  build() {
    Row() {
      Text(this.name)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
      Toggle({ type: ToggleType.Switch, isOn: this.value })
        .height(24)
        .width(48)
        .onChange((isOn) => {
          this.value = isOn
          isOn ? this.onaction() : this.offaction()
          this.action()
        })
        .selectedColor($r('app.color.app_red'))
    }
    .height(Constants.HEIGHT_SETTINGS_GROUP_ITEM)
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }
}

@Component export struct SliderSettingItem {
  @Link targetValue: number
  name: string = ''
  isPercent: boolean = false
  min: number = 0
  max: number = 0
  showValue: boolean = false
  step: number = 1
  changeAction = (): void => {}

  build() {
    Column() {
      Row() {
        Text(this.name)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
        Text(this.isPercent ? `${this.targetValue}%` : `${this.targetValue.toFixed(this.max === 1 ? 1 : 0)}`)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Bold)
          .visibility(this.showValue ? Visibility.Visible : Visibility.None)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ top: 10, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })

      Slider({
        value: this.targetValue,
        min: this.min,
        max: this.max,
        step: this.step
      })
        .selectedColor($r('app.color.app_red'))
        .blockColor($r('app.color.app_red'))
        .blockBorderWidth(0)
        .width('100%')
        .onChange((value, mode) => {
          if (mode !== SliderChangeMode.End) {
            animateTo({ duration: 100, curve: Curve.Linear }, () => {
              this.targetValue = value
              this.changeAction()
            })
            return
          }
        })
    }
    .height(Constants.HEIGHT_SETTINGS_ITEM)
  }
}