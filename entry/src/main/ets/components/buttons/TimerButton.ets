import Constants from "../../common/constants/Constants"
import { TimerSheet } from "../sheets/TimerSheet"

@Builder export function Timer() {
  TimerSheet()
}

@Component
export struct TimerButton {
  @Prop isTimerWorking: boolean = false
  @Link isShow: boolean
  @State wid: number = 30

  build() {
    Image($r('app.media.ic_timer_icon'))
      .fillColor(Color.White)
      .width(this.wid)
      .aspectRatio(1)
      .draggable(false)
      .backgroundColor(Color.Transparent)
      .onClick(() => { this.isShow = !this.isShow })
      .bindSheet(this.isShow, Timer(), {
        preferType: SheetType.CENTER,
        height: SheetSize.FIT_CONTENT,
        dragBar: false,
        showClose: true,
        backgroundColor: Color.Transparent,
        blurStyle: BlurStyle.Regular,
        onDisappear: () => { this.isShow = false }
      })
  }
}

@Component
export struct TimerButtonLarge {
  @Prop isTimerWorking: boolean = false
  @State isShow: boolean = false

  build() {
    Button() {
      Row({ space: 10 }) {
        Image($r('app.media.ic_clock'))
          .aspectRatio(1)
          .width(Constants.FONT_SIZE_TITLE + 5)
          .fillColor($r('app.color.reverse'))
        Text('定时关闭')
          .fontSize(Constants.FONT_SIZE_COMMON + 2)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.reverse'))
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
      }
      .width('100%')
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .backgroundColor(Color.Transparent)
    .buttonStyle(ButtonStyleMode.TEXTUAL)
    .borderRadius(5)
    .onClick(() => { this.isShow = !this.isShow })
    .bindSheet(this.isShow, Timer(), {
      preferType: SheetType.CENTER,
      height: SheetSize.FIT_CONTENT,
      dragBar: false,
      showClose: true,
      backgroundColor: $r('app.color.background'),
      onDisappear: () => { this.isShow = false }
    })
  }
}