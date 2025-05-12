import { BuilderNode, NodeController, PiPWindow } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { ClickUtil } from '@pura/harmony-utils';
import { StorageConstants } from '../../common/constants/StorageConstants';
import { FloatLyric } from '../../common/model/Settings';
import { changeSettings } from '../../common/functions/app/settings';
import { pauseMusic, playNext, playPre, playQueue, resumeMusic } from '../../common/functions/play/playControl';
import playQueueUtils from '../../common/utils/play/PlayQueueUtils';

class Params {
  text: string = '';

  constructor(text: string) {
    this.text = text;
  }
}

let floatLyricStyle = AppStorage.prop<FloatLyric>(StorageConstants.FLOAT_LYRIC_STYLE)

@Extend(Text)
function textStyle() {
  .fontSize(floatLyricStyle.get().size)
  .fontWeight(FontWeight.Bolder)
  .textAlign(floatLyricStyle.get().align === 'center' ? TextAlign.Center : TextAlign.Start)
  .layoutWeight(1)
  .width('100%')
  .maxLines(1)
  .fontColor($r('app.color.app_red'))
  .textShadow({  // 文字阴影增强
    radius: 2,
    color: $r('app.color.reverse'),
    offsetX: 2,
    offsetY: 2
  })
  .padding({ left: 10, right: 10 })
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Builder
function buildText(params: Params) {
  Stack({ alignContent: Alignment.Center }) {
    Text(params.text)
      .textStyle()
  }
  .width('100%')
  .height('100%')
  .backgroundColor($r('app.color.main'))
}

export class TextNodeController extends NodeController {
  private message: string;
  private textNode: BuilderNode<[Params]> | null = null;

  constructor(message: string) {
    super();
    this.message = message;
  }

  makeNode(context: UIContext): FrameNode | null {
    this.textNode = new BuilderNode(context);
    this.textNode.build(wrapBuilder<[Params]>(buildText), new Params(this.message));
    return this.textNode.getFrameNode();
  }

  update(message: string) {
    console.log(`update message: ${message}`);
    if (this.textNode !== null) {
      this.textNode.update(new Params(message));
    }
  }
}

class LyricsPipManager {
  private nodeController: TextNodeController = new TextNodeController("");
  private mXComponentController: XComponentController = new XComponentController();
  private pipController: PiPWindow.PiPController | undefined = undefined;
  private isPipStarted: boolean = false;

  public handleClickPip() {
    if (this.pipController) {
      if (this.isPipStarted) {
        this.pipController.stopPiP()
        this.isPipStarted = false
      } else {
        this.pipController.startPiP()
        this.isPipStarted = true
      }
    } else {
      this.startLyricsPip()
    }
  }

  public startPip() {
    if(!this.isPipStarted) {
      if(this.pipController) {
        this.pipController.startPiP()
        this.isPipStarted = true
      } else {
        this.startLyricsPip()
      }
    }
  }

  public stopPip() {
    if(this.pipController && this.isPipStarted) {
      this.pipController.stopPiP()
      this.isPipStarted = false
    }
  }

  public updateLyrics(currentLyric: string) {
    this.nodeController.update(currentLyric);
  }

  onStateChange(state: PiPWindow.PiPState, reason: string) {
    let newStyle = floatLyricStyle.get()
    switch (state) {
      case PiPWindow.PiPState.STARTED:
        this.isPipStarted = true
        newStyle.on = true
        changeSettings(StorageConstants.FLOAT_LYRIC_STYLE, newStyle)
        break
      case PiPWindow.PiPState.STOPPED:
        this.isPipStarted = false
        this.pipController = undefined
        newStyle.on = false
        changeSettings(StorageConstants.FLOAT_LYRIC_STYLE, newStyle)
        break
      case PiPWindow.PiPState.ERROR:
        this.isPipStarted = false
        this.pipController = undefined
        break
      default:
        break
    }
  }

  onActionEvent(control: PiPWindow.ControlEventParam) {
    switch (control.controlType) {
      case PiPWindow.PiPControlType.VIDEO_PLAY_PAUSE:
        if (control.status === PiPWindow.PiPControlStatus.PAUSE) {
          pauseMusic()
        } else if (control.status === PiPWindow.PiPControlStatus.PLAY) {
          if (AppStorage.get(StorageConstants.IS_PAUSED)) {
            resumeMusic();
            return;
          }
          setTimeout(() => {
            playQueue(playQueueUtils.currentQueueIndex)
          }, 100)
        }
        break;
      case PiPWindow.PiPControlType.VIDEO_NEXT:
        ClickUtil.throttle(() => {
          playNext()
        }, 500)
        break;
      case PiPWindow.PiPControlType.VIDEO_PREVIOUS:
        ClickUtil.throttle(() => {
          playPre()
        }, 500)
        break;
      default:
        break;
    }
    console.info('onActionEvent, controlType:' + control.controlType + ', status' + control.status);
  }

  private startLyricsPip() {
    let contentWidth: number = 140
    let contentHeight: number = 15
    let config: PiPWindow.PiPConfiguration = {
      context: getContext(this),
      componentController: this.mXComponentController,
      templateType: PiPWindow.PiPTemplateType.VIDEO_PLAY,
      contentWidth: contentWidth,
      contentHeight: contentHeight,
      controlGroups: [PiPWindow.VideoPlayControlGroup.VIDEO_PREVIOUS_NEXT],
      customUIController: this.nodeController,
    }

    let promise: Promise<PiPWindow.PiPController> = PiPWindow.create(config)
    promise.then((data: PiPWindow.PiPController) => {
      this.pipController = data
      this.pipController.setAutoStartEnabled(false);
      this.pipController.startPiP();
      this.pipController.on('controlEvent', (control: PiPWindow.ControlEventParam) => {
        this.onActionEvent(control);
      });
      this.pipController.on('stateChange', (state: PiPWindow.PiPState, reason: string) => {
        this.onStateChange(state, reason);
      });
      this.isPipStarted = true;
      console.info(`Succeeded in creating pip controller. Data:${data}`)
    }).catch((err: BusinessError) => {
      console.error(`Failed to create pip controller. Cause:${err.code}, message:${err.message}`)
    })
  }
}

export const lyricsPipManager = new LyricsPipManager()