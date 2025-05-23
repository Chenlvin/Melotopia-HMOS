import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { SetFloatLyric } from "../../components/settings/LyricSettings"

@Component
export struct FloatLyricPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  build() {
    NavDestination() {
      List({ space: 10 }) {
        ListItem() {
          SetFloatLyric()
        }
        .itemStyle()

        ListItem().padding({ bottom: px2vp(this.bottomRectHeight) + 30 })
      }
      .scrollBar(BarState.Off)
      .padding({ top: Constants.PADDING_EDGE_DEFAULT, left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .title($r('app.string.float_lyric'))
    .backgroundColor($r('app.color.background'))
  }

  @Styles itemStyle() {
    .backgroundColor($r('app.color.main'))
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT, top: 5, bottom: 5 })
    .margin({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(Constants.RADIUS_CARD)
  }
}