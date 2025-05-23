import Constants from "../../common/constants/Constants"

@Component
export struct CommonSettingsCard {
  @State title: string | ResourceStr = ''
  @State text: string | ResourceStr = ''
  action: () => void = () => {}

  build() {
    Button() {
      Row() {
        Text(this.title)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
        if (!this.text) {
          Image($r('app.media.ic_public_arrow_right'))
            .width(Constants.FONT_SIZE_TITLE)
            .fillColor(Color.Gray)
        } else {
          Text(this.text)
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(FontWeight.Bold)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .backgroundColor(Color.Transparent)
    .onClick(this.action)
    .height(Constants.HEIGHT_SETTINGS_ITEM)
  }
}