import { changeCycleMode } from "../../common/functions/play/playControl"

@Component
export struct LoopModeButton {
  @StorageLink('cycleMode') cycleMode:number = 0
  @State imgWidth: number = 30
  @State btnWidth: number = 30
  @State imgColor: Color | ResourceStr = $r('app.color.reverse')


  build() {
    // 0-顺序播放, 1-单曲循环, 2-顺序循环, 3-随机播放
    if(this.cycleMode == 0) {
      Button() { Image($r('app.media.ic_public_order_play')).image(this.imgWidth).fillColor(this.imgColor) }
      .button(this.btnWidth)
      .onClick(() => { changeCycleMode(1) })
    } else if(this.cycleMode == 1) {
      Button() { Image($r('app.media.ic_public_single_cycle')).image(this.imgWidth).fillColor(this.imgColor) }
      .button(this.btnWidth)
      .onClick(() => { changeCycleMode(2) })
    } else if(this.cycleMode == 2) {
      Button() { Image($r('app.media.ic_public_list_cycle')).image(this.imgWidth).fillColor(this.imgColor) }
      .button(this.btnWidth)
      .onClick(() => { changeCycleMode(3) })
    } else {
      Button() { Image($r('app.media.ic_public_random')).image(this.imgWidth - 5).fillColor(this.imgColor) }
      .button(this.btnWidth)
      .onClick(() => { changeCycleMode(0) })
    }
  }
}

@Extend(Button) function button(width: number = 30) {
  .backgroundColor(Color.Transparent)
  .width(width)
  .hoverEffect(HoverEffect.Scale)
  .stateEffect(false)
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
}

@Extend(Image) function image(width: number = 30) {
  .width(width)
  .draggable(false)
}