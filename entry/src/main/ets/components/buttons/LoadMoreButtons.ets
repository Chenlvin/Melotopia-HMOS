import Constants from "../../common/constants/Constants"

@Component
export struct ClickToLoadButton {
  build() {
    Button() {
      Text('加载更多')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor($r('app.color.reverse'))
    }
    .type(ButtonType.Normal)
    .borderRadius(Constants.RADIUS_CARD)
    .fontColor($r('app.color.reverse'))
    .width('100%')
    .backgroundColor(Color.Transparent)
    .height(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
  }
}

@Component
export struct LoadingMoreButton {
  build() {
    Row({ space: 10 }) {
      LoadingProgress()
        .width(Constants.SIZE_LOADING_PROGRESS_CARD)
        .color($r('app.color.reverse'))
      Text('正在加载...')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor($r('app.color.reverse'))
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .height(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
    .justifyContent(FlexAlign.Center)
  }
}

@Component
export struct NoMoreButton {
  build() {
    Column() {
      Text('没有更多了~')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor(Color.Gray)
    }
    .width('100%')
    .backgroundColor(Color.Transparent)
    .height(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
    .justifyContent(FlexAlign.Center)
  }
}