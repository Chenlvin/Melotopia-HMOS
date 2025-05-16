import { StorageConstants } from "../../common/constants/StorageConstants"
import { PlayQueue } from "../../common/model/PlayQueue"
import { PlayQueueSheet } from "../sheets/PlayQueueSheet"

@Component
export struct PlayQueueButton {
  @StorageProp('PlayQueue') queue: Array<PlayQueue> = []
  @StorageProp('currentQueueIndex') currentQueueIndex: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_HEIGHT) heightBp: string = 'md'
  @State isShow: boolean = false
  @State imgWidth: number = 30
  @State imgColor: Color | ResourceStr = $r('app.color.reverse')

  private sheetOptions: SheetOptions = {
    preferType: SheetType.BOTTOM,
    height: this.heightBp === 'sm' ? SheetSize.LARGE : '70%',
    dragBar: false,
    showClose: false,
    backgroundColor: $r('app.color.background'),
    onDisappear: () => { this.isShow = false }
  }

  build() {
    Button(){
      Image($r('app.media.ic_public_view_list_filled'))
        .width(this.imgWidth)
        .fillColor(this.imgColor)
        .draggable(false)
    }
    .stateEffect(false)
    .backgroundColor(Color.Transparent)
    .onClick(() => { this.isShow = !this.isShow })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .bindSheet(this.isShow, this.QueueComponent(), this.sheetOptions)
  }

  @Builder
  QueueComponent() {
    PlayQueueSheet({ isShow: this.isShow })
  }
}