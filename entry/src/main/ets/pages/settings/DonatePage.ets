import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { AppInfo, AppInfoClass } from "../../common/entities/AppInfo"

@Component
export struct DonatePage {
  @StorageProp(StorageConstants.APP_INFO) appInfo: AppInfo = AppInfoClass
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 30 }) {
          Image(this.appInfo.data.SponsorCode)
            .width('80%')
            .borderRadius(Constants.RADIUS_IMG)
            .constraintSize({
              maxWidth: 250,
              minWidth: 200
            })

          Column({ space: 20 }) {
            if(this.appInfo.data?.Sponsor.length > 0) {
              Text('特别鸣谢')
                .fontSize(Constants.FONT_SIZE_TITLE)
                .fontWeight(Constants.FONT_WEIGHT_BOLD)
                .fontColor($r('app.color.reverse'))
              Flex({
                wrap: FlexWrap.Wrap,
                justifyContent: FlexAlign.Center
              }) {
                ForEach(this.appInfo.data.Sponsor, (item: string) => {
                  Column() {
                    Text(item)
                      .fontWeight(FontWeight.Medium)
                      .fontColor($r('app.color.reverse'))
                      .padding(Constants.PADDING_EDGE_DEFAULT)
                      .backgroundColor($r('app.color.main'))
                      .borderRadius(Constants.RADIUS_CARD)
                  }
                  .padding(5)
                })
              }
              .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT})
            }

            Blank().height(px2vp(this.bottomRectHeight))
          }
        }
        .padding({ top: Constants.PADDING_EDGE_TEXT })
        .width('100%')
      }
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
      .height('100%')
      .width('100%')
      .layoutWeight(1)
      .align(Alignment.Top)
      .scrollBar(BarState.On)
      .scrollable(ScrollDirection.Vertical)
    }
    .title($r('app.string.sponsor'))
    .backgroundColor($r('app.color.background'))
  }
}