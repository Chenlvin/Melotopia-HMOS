import { StorageConstants } from "../../common/constants/StorageConstants"
import { display, window } from "@kit.ArkUI"
import Constants from "../../common/constants/Constants";
import { LogUtil } from "@pura/harmony-utils";
import { FloatLyric, FloatLyric_INITIAL, LyricPosition } from "../../common/model/Settings";
import WindowUtils from "../../common/utils/system/WindowUtils";
import { changeSettings } from "../../common/functions/app/settings";

const TAG = 'FloatingLyrics'
const BOTTOM_MARGIN = vp2px(60)
const THRESHOLD = vp2px(20)

class FloatingLyricsController {
  win: window.Window | null = null;
  public displayH = display.getDefaultDisplaySync().height
  public displayW = display.getDefaultDisplaySync().width
  windowPosition: LyricPosition = { x: 0, y: 0 }
  floatLyricStyle = AppStorage.prop<FloatLyric>(StorageConstants.FLOAT_LYRIC_STYLE)

  public init() {
    try {
      this.win = window.findWindow(Constants.FLOAT_LYRICS_WIN_NAME)
      this.win.setWindowBackgroundColor("#00000000") // transparent
      this.win.setWindowFocusable(false)
    } catch (err) {
      LogUtil.error(TAG, "init err")
    }
  }

  public destroyWindow = () => {
    try {
      WindowUtils.destoryLyricFloatWindow()
      this.floatLyricStyle.get().on = false
      changeSettings(StorageConstants.FLOAT_LYRIC_STYLE, this.floatLyricStyle.get())
    } catch (err) {
      LogUtil.error(TAG, "destroyWindow err")
    }
  }
  public handlePanGestureStart = (event: GestureEvent): void => {
    if (!this.win) {
      return
    }
    this.windowPosition = { x: this.windowPosition.x, y: this.win.getGlobalRect().top }
  }

  public handlePanGestureUpdate = (event: GestureEvent): void => {
    // if (Math.abs(event.offsetY) < 1 || Math.abs(event.offsetX) < 1)
    //   return

    let resY = this.windowPosition.y + event.offsetY
    let resX = this.windowPosition.x + event.offsetX
    let limitX = this.displayW * this.floatLyricStyle.get().width / 100
    if(resY < 0) resY = 0
    else if(resY > this.displayH - BOTTOM_MARGIN + THRESHOLD )
      resY = this.displayH - BOTTOM_MARGIN + THRESHOLD
    if(resX < 0) resX = 0
    else if(resX > this.displayW - limitX)
      resX = this.displayW - limitX

    this.windowPosition.y = resY
    this.windowPosition.x = resX
    this.floatLyricStyle.get().position.y = WindowUtils.getScreenPercentageY(resY)
    this.floatLyricStyle.get().position.x = WindowUtils.getScreenPercentageX(resX)
    changeSettings(StorageConstants.FLOAT_LYRIC_STYLE, this.floatLyricStyle.get())
    this.moveWindowTo(resX, resY)
  }

  public onTouchableChange(floatTouchable: boolean) {
    try {
      this.win?.setWindowTouchable(floatTouchable);
    } catch (err) {
      LogUtil.error(TAG, "onTouchableChange err");
    }
  }

  moveWindowTo(x: number, y: number) {
    try {
      this.win!.moveWindowTo(x, y);
    } catch (err) {
      LogUtil.error(TAG, "moveWindow err");
    }
  }
}

@Entry
@Component
export struct FloatingLyrics {
  @StorageProp(StorageConstants.IS_PLAYER_SHOW) isPlayerShow: boolean = false
  @StorageProp(StorageConstants.CURRENT_LYRIC) currentLyric: string = '';
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = '';
  @StorageProp(StorageConstants.FLOAT_LYRIC_STYLE) @Watch('onLyricStyleChange') floatLyricStyle: FloatLyric = FloatLyric_INITIAL
  private controller: FloatingLyricsController = new FloatingLyricsController();

  aboutToAppear(): void {
    this.controller.init();
    this.controller.onTouchableChange(this.floatLyricStyle.touchable);
  }

  onLyricStyleChange() {
    this.controller.onTouchableChange(this.floatLyricStyle.touchable);
    this.controller.moveWindowTo(WindowUtils.getScreenResX(this.floatLyricStyle.position.x),
      WindowUtils.getScreenResY(this.floatLyricStyle.position.y))
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Text(this.currentLyric)
        .textStyle(this.floatLyricStyle.size)
        .textAlign(this.floatLyricStyle.align === 'center' ? TextAlign.Center : TextAlign.Start)
    }
    .width(`${this.floatLyricStyle.width}%`)
    .backgroundColor(Color.Transparent)
    .opacity(this.floatLyricStyle.opacity)
    .visibility(this.isPlayerShow ? Visibility.None : Visibility.Visible)
    .animation({ duration: 500, curve: Curve.Smooth })
    .backdropBlur(this.floatLyricStyle.bgBlur ? 50 : 0)
    .borderRadius(Constants.RADIUS_IMG)
    .parallelGesture(GestureGroup(GestureMode.Exclusive,
      TapGesture({ count: 2, fingers: 1 })
        .onAction(this.controller.destroyWindow),
      PanGesture({ direction: PanDirection.All })
        .onActionStart(this.controller.handlePanGestureStart)
        .onActionUpdate(this.controller.handlePanGestureUpdate)
    ))
  }
}

@Extend(Text)
function textStyle(size: number) {
  .fontSize(size)
  .fontColor($r('app.color.app_red'))
  .fontWeight(Constants.FONT_WEIGHT_BOLD)
  .width('100%')
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.MARQUEE })
  .padding(5)
}