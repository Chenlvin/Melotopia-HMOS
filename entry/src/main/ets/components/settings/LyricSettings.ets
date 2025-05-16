import { EmitterUtil } from "@pura/harmony-utils";
import Constants from "../../common/constants/Constants";
import { EmitterConstants } from "../../common/constants/EmitterConstants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import { FloatLyric, FloatLyric_INITIAL,
  LyricStyle, LyricStyle_INITIAL } from "../../common/model/Settings";
import { changeSettings } from "../../common/functions/app/settings";
import { lyricsPipManager } from "../../pages/lyrics/PipLyrics";
import { SliderSettingItem, ToggleSettingItem } from "./SettingsItem";

@Component
export struct LyricTranslate {
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyle_INITIAL

  build() {
    Column({ space: 5 }) {
      Text('启用歌词翻译')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
        .textAlign(TextAlign.Start)
        .width('100%')

      Row({ space: 10 }) {
        this.LyricTranItem(0, '无')
        this.LyricTranItem(1, '翻译')
        this.LyricTranItem(2, '罗马音')
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
    .height(Constants.HEIGHT_SETTINGS_ITEM * 2)
    .justifyContent(FlexAlign.SpaceEvenly)
  }

  @Builder LyricTranItem(type: number, text: string) {
    Row() {
      Radio({ value: `${type}` , group: 'lyricTranslation' })
        .checked(this.lyricStyle.mode === type)
        .radioStyle({ checkedBackgroundColor: $r('app.color.app_red') })
        .onChange(async (isChecked) => {
          if(isChecked) {
            this.lyricStyle.mode = type
            await changeSettings(StorageConstants.LYRIC_STYLE, this.lyricStyle)
            EmitterUtil.post(EmitterConstants.EMITTER_LYRIC_UPDATE, () => {})
          }
        })
      Text(text)
        .fontColor($r('app.color.reverse'))
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Start)
        .lineHeight(20)
    }
  }
}

@Component
export struct SetLyricStyle {
  @StorageProp(StorageConstants.LYRIC_STYLE) lyricStyle: LyricStyle = LyricStyle_INITIAL
  @State style: LyricStyle = LyricStyle_INITIAL
  @State isCenter: boolean = false
  @State fontSize: number = 0

  aboutToAppear(): void {
    this.style = this.lyricStyle
    this.fontSize = this.lyricStyle.size
    this.isCenter = this.lyricStyle.align === 'center' ? true : false
  }

  build() {
    Column({ space: 20 }) {

      ToggleSettingItem({ name: '歌词居中显示', value: this.isCenter ,
        onaction: () => { this.lyricStyle.align = 'center' },
        offaction: () => { this.lyricStyle.align = 'start' },
        action: () => { this.updateLyricStyle() }
      })
      .padding({ top: Constants.PADDING_EDGE_DEFAULT })

      SliderSettingItem({ name: '歌词字体大小', showValue: true, targetValue: this.fontSize,
        min: 10, max: 40, changeAction: () => {
          this.lyricStyle.size = this.fontSize
          this.updateLyricStyle()
        }
      })

      Text('效果预览')
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Bold)
        .width('100%')
        .textAlign(TextAlign.Start)
        .padding(Constants.PADDING_EDGE_DEFAULT)

      Column({ space: 15 }) {
        Text('When your dreams come alive you\'re unstoppable')
          .lyricStyle(this.lyricStyle.size, this.lyricStyle.align).scale({ x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0 })
        Text('我一路向北 离开有你的季节')
          .lyricStyle(this.lyricStyle.size, this.lyricStyle.align).opacity(1)
        Text('君と集まって星座になれたら')
          .lyricStyle(this.lyricStyle.size, this.lyricStyle.align).scale({ x: 0.9, y: 0.9, centerX: this.lyricStyle.align === 'center' ? '50%' : 0})
      }
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    }

  }

  private updateLyricStyle() {
    this.style = this.lyricStyle
    changeSettings(StorageConstants.LYRIC_STYLE, this.style)
  }
}

@Component
export struct SetFloatLyric {
  @StorageProp(StorageConstants.FLOAT_LYRIC_STYLE) floatLyric: FloatLyric = FloatLyric_INITIAL
  @State wid: number = 0
  @State fontsize: number = 0
  @State fontopacity: number = 0
  @State bgBlur: boolean = false
  @State isOn: boolean = false
  @State positionX: number = 0
  @State positionY: number = 0
  @State fontCenter: boolean = false
  @State lyricDraggable: boolean = false
  @StorageProp(StorageConstants.CURRENT_LYRIC) currentLyric: string = ''

  aboutToAppear(): void {
    this.isOn = this.floatLyric.on
    this.wid = this.floatLyric.width
    this.fontsize = this.floatLyric.size
    this.fontopacity = this.floatLyric.opacity
    this.bgBlur = this.floatLyric.bgBlur
    this.positionX = this.floatLyric.position.x
    this.positionY = this.floatLyric.position.y
    this.fontCenter = this.floatLyric.align === 'center' ? true : false
    this.lyricDraggable = this.floatLyric.touchable
  }

  build() {
    Column({ space: 20 }) {
      ToggleSettingItem({ name: '启用浮动歌词', value: this.isOn,
        onaction: () => { this.floatLyric.on = true; lyricsPipManager.startPip() },
        offaction:() => { this.floatLyric.on = false; lyricsPipManager.stopPip() },
        action: () => { this.updateFloatLyric() }
      })
        .padding({ top: Constants.PADDING_EDGE_DEFAULT })

      // ToggleSettingItem({ name: '背景模糊', value: this.bgBlur,
      //   action: () => {
      //     this.floatLyric.bgBlur = this.bgBlur
      //     this.updateFloatLyric()
      //   }})
      //
      // ToggleSettingItem({ name: '浮动歌词拖动', value: this.lyricDraggable,
      //   action: () => {
      //     this.floatLyric.touchable = this.lyricDraggable
      //     this.updateFloatLyric()
      //   }})

      ToggleSettingItem({ name: '浮动歌词居中', value: this.fontCenter,
        onaction: () => { this.floatLyric.align = 'center' },
        offaction: () => { this.floatLyric.align = 'start' },
        action: () => { this.updateFloatLyric() }
      })

      SliderSettingItem({ name: '浮动歌词字体大小', min: 5, max: 22, targetValue: this.fontsize, changeAction: () => {
        this.floatLyric.size = this.fontsize; this.updateFloatLyric()
      }})
        .padding({ bottom: Constants.PADDING_EDGE_TEXT})

      // SliderSettingItem({ name: '浮动歌词宽度', min: 10, max: 100, isPercent: true, targetValue: this.wid, changeAction: () => {
      //   this.floatLyric.width = this.wid; this.updateFloatLyric()
      // }})

      // SliderSettingItem({ name: '浮动歌词透明度', min: 0.1, max: 1, step: 0.1, targetValue: this.fontopacity, changeAction: () => {
      //   this.floatLyric.opacity = this.fontopacity; this.updateFloatLyric()
      // }})

      // SliderSettingItem({ name: '上下调节', min: 0, max: 100, step: 0.1, targetValue: this.positionY, changeAction: () => {
      //   this.floatLyric.position.y = this.positionY; this.updateFloatLyric()
      // }})
      //
      // SliderSettingItem({ name: '左右调节', min: 0, max: 100, step: 0.1, targetValue: this.positionX, changeAction: () => {
      //   this.floatLyric.position.x = this.positionX; this.updateFloatLyric()
      // }})
      //   .padding({ bottom: Constants.PADDING_EDGE_TEXT})
    }
  }

  private async updateFloatLyric() {
    await changeSettings(StorageConstants.FLOAT_LYRIC_STYLE, this.floatLyric)
    lyricsPipManager.updateLyrics(this.currentLyric)
  }
}

@Extend(Text) function lyricStyle(size: number, align: string) {
  .width('100%')
  .textAlign(TextAlign.Center)
  .fontSize(size)
  .fontColor($r('app.color.reverse'))
  .opacity(0.35)
  .fontWeight(FontWeight.Bold)
  .textAlign(align === 'center' ? TextAlign.Center : TextAlign.Start)
}
