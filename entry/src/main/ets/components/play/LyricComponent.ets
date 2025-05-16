import { EmitterUtil } from "@pura/harmony-utils"
import { Lyric } from "../../common/entities/Lyric"
import { seekMusic } from "../../common/functions/play/playControl"
import { LengthUnit } from "@kit.ArkUI"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { LyricStyle, LyricStyle_INITIAL } from "../../common/model/Settings"
import LyricUtils from "../../common/utils/play/LyricUtils"
import { LazyData } from "@pie/lazy-data"
import Constants from "../../common/constants/Constants"

@Component
export struct LyricComponent {
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @StorageProp(StorageConstants.CURRENT_LYRIC_INDEX) @Watch('ToCurrentLyric') currentLyricIndex: number = 0
  @StorageProp(StorageConstants.IS_IN_FOREGROUND) @Watch('onForegroundState') isInForeground: boolean = true
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyle_INITIAL
  @StorageProp(StorageConstants.NEW_LYRIC_EFFECT) newLyricEffect: boolean = true
  @State firstLoad: boolean = true
  @State userScrolling: number = 0
  @State userScrollingInterval: number = 0
  @State lyric: Lyric[] = []
  @State dataSource: LazyData<Lyric> = new LazyData()
  @State isLoading: boolean = false
  @State needUpdate: boolean = false

  private scroller: Scroller = new Scroller()

  onForegroundState() {
    if(this.isInForeground === true && this.needUpdate) {
      this.refreshLyric()
      this.needUpdate = false
    }
  }

  async aboutToAppear(): Promise<void> {
    await this.getLyric()
    setTimeout(() => {
      this.scroller.scrollToIndex(this.currentLyricIndex, false, ScrollAlign.CENTER)
    }, 10)
    this.StartAutoScrollTimer()
  }

  refreshLyric = async () => {
    this.currentLyricIndex = 0
    this.needUpdate = true
    this.isLoading = true
    await this.getLyric()
    setTimeout(() => {
      this.isLoading = false
    }, 100)
    setTimeout(() => {
      this.ToCurrentLyric()
    }, 300)
  }

  aboutToDisappear(): void {
    clearInterval(this.userScrollingInterval)
  }

  private StartAutoScrollTimer() {
    this.userScrollingInterval = setInterval(() => {
      if(this.userScrolling > 0) {
        this.userScrolling -= 1
      } else if(this.userScrolling === 0) {
        this.ToCurrentLyric()
      }
    }, 1000)
  }

  async getLyric() {
    this.lyric = await LyricUtils.getLyricObjects()
    this.dataSource.setData(this.lyric)
    this.dataSource.notifyDataReload()
  }

  ToCurrentLyric() {
    if(!this.userScrolling && !this.isLoading) {
      this.scroller.scrollToIndex(this.currentLyricIndex + 1, true, ScrollAlign.CENTER)
    }
  }

  build() {
    List({ scroller: this.scroller }) {
      if(!this.isLoading) {
        ListItem().height('50%')
        if(this.newLyricEffect) {
          LazyForEach(this.dataSource, (item: Lyric, index) => {
            LyricLine({
              lyricStyle: this.lyricStyle,
              currentLyricIndex: this.currentLyricIndex,
              userScrolling: this.userScrolling,
              index: index,
              item: item
            })
              .offset({ y: this.Offset(index) })
              .animation({
                delay: this.userScrolling ? 0 : this.Delay(index),
                duration: this.userScrolling ? 0 : 600,
                curve: Curve.Smooth,
                expectedFrameRateRange: {
                  expected: 90,
                  min: 60,
                  max: 90
                }
              })
              .padding({
                bottom: !this.userScrolling
                  ? (index >= this.currentLyricIndex ? this.lyricStyle.size : this.lyricStyle.size * 2)
                  : this.lyricStyle.size * 2
              })
              .animation({ duration: this.userScrolling ? 0 : 300, curve: Curve.Friction })
          })
        } else {
          LazyForEach(this.dataSource, (item: Lyric, index) => {
            LyricLine({
              lyricStyle: this.lyricStyle,
              currentLyricIndex: this.currentLyricIndex,
              userScrolling: this.userScrolling,
              index: index,
              item: item
            })
              .padding({ bottom: this.lyricStyle.size * 2 })
          })
        }
        ListItem().height('50%')
      }
    }
    .cachedCount(3)
    .alignListItem(ListItemAlign.End)
    .padding({ top: 30 })
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring)
    .listDirection(Axis.Vertical)
    .scrollBar(BarState.Off)
    .fadingEdge(true, {
      fadingEdgeLength: {
        unit: LengthUnit.PERCENT,
        value: 40
      }
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Move) {
        this.userScrolling = 2
      }
    })
    .onAppear(() => {
      EmitterUtil.onSubscribe(EmitterConstants.EMITTER_LYRIC_UPDATE, this.refreshLyric)
    })
    .onDisAppear(() => {
      EmitterUtil.unSubscribe(EmitterConstants.EMITTER_LYRIC_UPDATE)
    })
  }

  Offset(index: number) {
    if(this.userScrolling) return 0
    const LINE_SPACING = this.lyricStyle.size
    const delta = index - this.currentLyricIndex
    let offset = delta > 0 ? delta * LINE_SPACING : 0
    return offset
  }

  Delay(index: number) {
    if(this.userScrolling) return 0
    const delta = index - this.currentLyricIndex
    return Math.max(delta * 80, 0)
  }

}

@Reusable
@Component
struct LyricLine {
  @State index: number = 0
  @State item: Lyric = { time: 0, content: ''}
  @Prop currentLyricIndex: number = 0
  @Prop lyricStyle: LyricStyle = LyricStyle_INITIAL
  @Link userScrolling: number

  aboutToReuse(params: ESObject): void {
    this.index = params.index
    this.item = params.item as Lyric
  }

  build() {
    Text(this.item.content)
      .width('100%')
      .textAlign(TextAlign.Center)
      .fontSize(this.lyricStyle.size)
      .lineHeight(this.lyricStyle.size * 1.3)
      .fontColor(Color.White)
      .opacity(this.index == this.currentLyricIndex ? 1 : 0.35)
      .fontWeight(Constants.FONT_WEIGHT_BOLD)
      .textAlign(this.lyricStyle.align === 'center' ? TextAlign.Center : TextAlign.Start)
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
      .padding({ left: 20, right: 20 })
      .scale(this.index === this.currentLyricIndex ?
        { x: 1.0, y: 1.0, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 } :
        { x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 })
      .onClick(() => {
        seekMusic(this.item.time + 100)
        setTimeout(() => {
          this.userScrolling = 0
        }, 100)
      })
      .animation({
        duration: 500,
        curve: Curve.Smooth,
        expectedFrameRateRange: {
          expected: 90,
          min: 60,
          max: 90
        }
      })
  }
}
