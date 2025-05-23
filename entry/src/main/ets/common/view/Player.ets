import { Song, Song_INITIAL } from "../entities/Song"
import { changeDuration } from "../functions/common/convert"
import { pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../functions/play/playControl"
import { AddToPlayListCircleButton } from "../../components/buttons/AddToPlayListButton"
import { LoopModeButton } from "../../components/buttons/LoopModeButton"
import { PlayQueueButton } from "../../components/buttons/PlayQueueButton"
import { LyricComponent } from "../../components/play/LyricComponent"
import { AVCastPicker } from "@kit.AVSessionKit"
import { TimerButton } from "../../components/buttons/TimerButton"
import { StorageConstants } from "../constants/StorageConstants"
import Constants from "../constants/Constants"
import { ClickUtil, EmitterUtil, PasteboardUtil, ToastUtil } from "@pura/harmony-utils"
import { PlayerActionSheet } from "../../components/sheets/PlayerActionSheet"
import { likeThisSong } from "../functions/play/songLike"
import { resourceManager } from "@kit.LocalizationKit"
import { PlayConstants } from "../constants/PlayConstants"
import { ArtistsSheet } from "../../components/sheets/ArtistsSheet"
import { window } from "@kit.ArkUI"
import OrientationUtils from "../utils/system/WindowUtils"
import { EmitterConstants } from "../constants/EmitterConstants"
import { PLAYMODE } from "../model/Enum"
import { PersonalFmMenu } from "../../components/menu/PersonalFmMenu"
import { PlaySettingSinglePage } from "../../pages/settings/PlaySettingsPage"
import AVPlayerUtils from "../utils/play/AVPlayerUtils"
import Storage from "@system.storage"

@Component
export struct Player {
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @StorageProp(StorageConstants.PLAY_MODE) playmode: PLAYMODE = PLAYMODE.SINGLE
  @StorageProp(StorageConstants.PLAY_SONG) song: Song = Song_INITIAL
  @StorageProp(StorageConstants.PLAY_ARTISTS) artists: string = ''
  @StorageProp(StorageConstants.IS_PAUSED) isPaused: boolean = false
  @StorageProp(StorageConstants.PIC_URL) picUrl: string = ''
  @StorageProp(StorageConstants.PLAY_TIME) time: number = 0
  @StorageProp(StorageConstants.ISLIKED) isLiked: boolean = false
  @StorageProp(StorageConstants.PLAY_COUNTDOWN_WORKING) isTimerWorking: boolean = false
  @StorageProp(StorageConstants.PLAY_IS_LOCALFILE) isLocalFile: boolean = false
  @StorageProp(StorageConstants.IS_PERSONAL_FM) isPersonalFm: boolean = false
  @StorageProp(StorageConstants.PERSONAL_FM_MODE) personalFmMode: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) widBp: string = 'sm'
  @StorageProp(StorageConstants.BREAKPOINT_HEIGHT) heightBp: string = 'sm'
  @StorageProp(StorageConstants.DEVICE_TYPE) deviceType: resourceManager.DeviceType = resourceManager.DeviceType.DEVICE_TYPE_PHONE
  @StorageProp(StorageConstants.WINDOW_STATUS_TYPE) windowStatusType: window.WindowStatusType = window.WindowStatusType.UNDEFINED
  @StorageLink(StorageConstants.IS_PLAYER_SHOW) isPlayerShow: boolean = false
  @Link isShow: boolean
  @State sliderThickness: number = 10
  @State isMovingSlider: boolean = false
  @State sliderMovingTime: number = 0
  @State isShowMenu: boolean = false
  @State isShowTimer: boolean = false
  @State isShowAddSheet: boolean = false
  @State isShowArtists: boolean = false
  @State isShowSettings: boolean = false
  @State isLikeProcessing: boolean = false
  @State totalOpacity: number = 0

  private settingsSheetOptions: SheetOptions = {
    backgroundColor: Color.Transparent,
    showClose: false,
    height: SheetSize.LARGE,
    dragBar: false,
    blurStyle: BlurStyle.Regular,
    preferType: SheetType.CENTER,
    onDisappear: () => { this.isShowSettings = false }
  }

  private artistsSheetOptions: SheetOptions = {
    preferType: SheetType.CENTER,
    height: SheetSize.FIT_CONTENT,
    dragBar: false,
    showClose: false,
    backgroundColor: Color.Transparent,
    blurStyle: BlurStyle.Regular,
    onDisappear: () => { this.isShowArtists = false }
  }

  aboutToAppear(): void {
    this.isPlayerShow = true
    setTimeout(() => {
      animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
        this.totalOpacity = 0.5
      })
      EmitterUtil.onSubscribe(EmitterConstants.PLAYING_COVER_TOGGLE, (toggle: boolean) => {
        this.isShow = toggle
      })
    }, 500)
  }

  aboutToDisappear(): void {
    this.isPlayerShow = false
    OrientationUtils.setOrientation(window.Orientation.AUTO_ROTATION_UNSPECIFIED)
    EmitterUtil.unSubscribe(EmitterConstants.PLAYING_COVER_TOGGLE)
  }

  // Slider OnChange
  private handleSliderChange = (value: number, mode: SliderChangeMode) => {
    animateTo({ duration: 500, curve: Curve.Smooth, }, () => {
      if (mode == SliderChangeMode.Begin) {
        this.isMovingSlider = true
        this.sliderMovingTime = value
        this.sliderThickness = 15
      } else if (mode == SliderChangeMode.Moving) {
        this.sliderMovingTime = value
      } else if (mode == SliderChangeMode.End) {
        this.time = value
        this.sliderThickness = 10
        this.isMovingSlider = false
        seekMusic(this.sliderMovingTime)
      }
    })
  }

  private handleLike = async () => {
    if(this.isLikeProcessing) return
    else if(this.song.id === 0 || this.playmode === PLAYMODE.DJRADIO || this.playmode === PLAYMODE.LOCAL) {
      ToastUtil.showToast('当前播放歌曲不支持该操作')
      return
    }
    this.isLikeProcessing = true
    try {
      await likeThisSong()
      AVPlayerUtils.syncSessionState()
    } finally {
      this.isLikeProcessing = false
    }
  }

  build() {
   Stack() {
     // Background
     Stack() {
       Image(this.playmode === PLAYMODE.LOCAL ? this.picUrl ? this.picUrl : $r('app.media.bg_default') : this.picUrl + '?param=512y512')
         .blur(100)
         .width('100%')
         .height('100%')
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
       Column()
         .width('100%')
         .height('100%')
         .opacity(0.6)
         .backgroundColor(Color.Black)
         .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
     }
     .width('100%')
     .height('100%')

     /**
      * 主内容
      */
     // Tablet & 2in1
     if((this.widBp === 'lg' && this.heightBp !== 'sm') ||
         (this.widBp === 'md' && this.heightBp === 'md')) {
       this.LargeUI()
     }
     // Phone Landscape
     else if(this.heightBp === 'sm' && this.widBp !== 'sm') {
       this.PhoneLandscapeUI()
     }
     // Pura X Small
     else if(this.heightBp === 'sm' && this.widBp === 'sm' && this.windowStatusType !== window.WindowStatusType.FLOATING) {
       this.SmallUI()
     }
     // Default - Phone
     else {
       this.PhoneUI()
     }

     /**
      * Head栏
      */
     this.Head()
   }
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .bindSheet(this.isShowSettings, this.SettingsSheet(), this.settingsSheetOptions)
  }

  /**
   * 功能栏
   */
  @Builder
  ToolBar(size: number = 25) {
    Row() {
      /**
       * Heart
       */
      Image(this.isLiked || this.playmode === PLAYMODE.LOCAL ? $r('app.media.ic_public_favor_filled') : $r('app.media.ic_public_favor'))
        .fillColor(Color.White)
        .height(size)
        .aspectRatio(1)
        .draggable(false)
        .backgroundColor(Color.Transparent)
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .onClick(this.handleLike)

      TimerButton({ isTimerWorking: this.isTimerWorking, isShow: this.isShowTimer, wid: 20 })
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .visibility(Visibility.Hidden)

      /**
       * AddToPlayList
       */
      AddToPlayListCircleButton({
        song: this.song,
        imgColor: Color.White,
        imgHeight: 0,
        isShowAddSheet: this.isShowAddSheet,
        isLarge: (this.widBp === 'md' && this.heightBp === 'sm')
      })
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .visibility(Visibility.Hidden)

      /**
       * More
       */
      Image($r('app.media.ic_more_vertical_o_icon'))
        .fillColor(Color.White)
        .height(size - 2)
        .aspectRatio(1)
        .draggable(false)
        .backgroundColor(Color.Transparent)
        .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
        .bindSheet(this.isShowMenu, this.PlayerActionSheet(), {
          backgroundColor: Color.Transparent,
          showClose: false,
          height: this.heightBp === 'sm' ? SheetSize.LARGE : '60%',
          dragBar: false,
          blurStyle: BlurStyle.Regular,
          preferType: SheetType.CENTER,
          onDisappear: () => { this.isShowMenu = false }
        })
        .onClick(() => {
          this.isShowMenu = true
        })
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .height(size + 5)
    .opacity(0.5)
  }

  /**
   * 进度条组件
   */
  @Builder
  SliderContent() {
    Column() {
      // 进度条
      Slider({
        value: this.time,
        min: 0,
        max: this.song.duration,
        step: 1,
        style: SliderStyle.InSet
      })
        .width('100%')
        .trackColor(Color.Gray)
        .trackThickness(this.sliderThickness)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .onChange(this.handleSliderChange)

      Row() {
        // 当前时间
        Text(`${changeDuration(this.time)}`)
          .fontSize(12)
          .textAlign(TextAlign.Start)
          .fontColor(Color.White)
          .alignSelf(ItemAlign.Start)
          .layoutWeight(1)

        // 拖动进度条时，显示即将跳转的时间
        Text(`${changeDuration(this.sliderMovingTime)}`)
          .fontSize(12)
          .fontColor(Color.White)
          .backgroundColor(Color.Gray)
          .borderRadius(Constants.RADIUS_CARD)
          .textAlign(TextAlign.Center)
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .alignSelf(ItemAlign.Center)
          .visibility(this.isMovingSlider ? Visibility.Visible : Visibility.Hidden)

        // 总时间
        Text(`${changeDuration(this.song.duration)}`)
          .fontSize(12)
          .textAlign(TextAlign.End)
          .fontColor(Color.White)
          .alignSelf(ItemAlign.End)
          .layoutWeight(1)
      }
      .padding({ bottom: Constants.PADDING_MEDIUM, left: 5, right: 5 })
      .width('100%')
    }
    .width('100%')
    .opacity(0.6)
  }

  @Builder
  PhoneLandscapeSlider(wid: string | number = '80%') {
    Row() {
      Slider({
        value: this.time,
        min: 0,
        max: this.song.duration,
        step: 1,
        style: SliderStyle.InSet
      })
        .layoutWeight(1)
        .trackColor(Color.Gray)
        .trackThickness(this.sliderThickness)
        .selectedColor(Color.White)
        .showSteps(false)
        .showTips(false)
        .onChange(this.handleSliderChange)

      Text() {
        Span(this.isMovingSlider ? `${changeDuration(this.sliderMovingTime)}` : `${changeDuration(this.time)}`)
        Span(' / ')
        Span(`${changeDuration(this.song.duration)}`)
      }
        .fontSize(12)
        .textAlign(TextAlign.Start)
        .fontColor(Color.White)
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    .width(wid)
    .opacity(0.5)
  }

  /**
   * PlayButton
   * 控制上一首、下一首、播放和暂停
   */
  @Builder
  PlayButton(size: number) {
    // 上一首
    Image($r('app.media.ic_public_play_last')).buttonImgStyle(size)
    .onClick(() => {
      ClickUtil.throttle(() => {
        playPre()
      }, 500)
    })

    // 暂停、继续
    Image(!this.isPaused ? $r('app.media.ic_public_pause') : $r('app.media.ic_play_fill')).buttonImgStyle(size)
      .onClick(() => {
        if(this.isPaused) {
          resumeMusic()
        } else {
          pauseMusic()
        }
      })

    // 下一首
    Image($r('app.media.ic_public_play_next')).buttonImgStyle(size)
    .onClick(() => {
      ClickUtil.throttle(() => {
        playNext()
      }, 500)
    })
  }

  /**
   * Head
   */
  @Builder
  Head() {
    Row() {
      Button({ type: ButtonType.Circle }) { Image($r('app.media.ic_public_arrow_down_0')).draggable(false).fillColor(Color.White).width(Constants.SIZE_ICON_BUTTON_COMMON).aspectRatio(1) }
      .backgroundColor(Color.Transparent)
      .onClick(() => { this.isShow = false })

      /**
       * AVCastPicker
       */
      Column() {
        AVCastPicker({
          normalColor: Color.White,
          sessionType: 'audio'
        })
          .width(23)
          .height(23)
          .backgroundColor(Color.Transparent)
      }
    }
    .position({ top: 0 })
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: px2vp(this.topRectHeight) + 5 , left: 10, right: 10, bottom: 5 })
    .opacity(this.totalOpacity)
  }

  /**
   * Information
   */
  @Builder
  SongInfo() {
    Column({ space: Constants.PADDING_MEDIUM }) {
      this.PersonalFmButton()

      Column({ space: Constants.PADDING_MEDIUM }) {
        // 歌曲封面图片
        Column() {
          Image(this.playmode === 0 ? this.picUrl : this.picUrl + '?param=512y512')
            .aspectRatio(1)
            .height(this.song.id === 0 ? '70%' : '100%')
            .borderRadius(5)
            .scale({ x: this.isPaused ? 0.9 : 1.0, y: this.isPaused ? 0.9 : 1.0})
            .animation({ duration: 300, curve: Curve.Smooth })
            .gesture(
              TapGesture({
                count: 2,
              }).onAction(this.handleLike)
            )
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .aspectRatio(1)
        .constraintSize({
          minWidth: 0,
          maxWidth: '100%',
          minHeight: 0,
          maxHeight: 500
        })

        Row({ space: 10 }) {
          Column({ space: 10 }) {
            // 歌曲名称&歌手
            Text(this.song.name)
              .textStyle(24)
              .fontWeight(FontWeight.Bold)
              .onClick(() => {
                PasteboardUtil.setDataText(this.song.name)
                ToastUtil.showToast('已复制歌名到剪贴板', { duration: 3000 })
              })
            Text(this.artists)
              .textStyle(16)
              .onClick(() => {
                if(this.song.id !== 0 && this.playmode !== 3) {
                  this.isShowArtists = true
                }
              })
              .bindSheet(this.isShowArtists, this.ArtistsSheet(), this.artistsSheetOptions)
          }
          .layoutWeight(1)

          this.ToolBar()
        }
        .width('100%')
        .constraintSize({
          minWidth: 0,
          maxWidth: 500
        })
      }
      .justifyContent(FlexAlign.Center)
      .layoutWeight(1)

      Column() {
        this.SliderContent()
        this.ControllButtons()
        Row({ space: 15 }) {
          if(this.isLocalFile || this.playmode == 0) { Text('本地文件播放中').fontSize(10).fontColor(Color.Gray) }
          if(this.isTimerWorking) { Text('已设置定时关闭').fontSize(10).fontColor(Color.Gray) }
        }
        .height(30)
      }
      .width('100%')
      .constraintSize({
        minWidth: 0,
        maxWidth: 500
      })
    }
    .width('100%')
    .padding({ left: Constants.PADDING_MEDIUM, right: Constants.PADDING_MEDIUM, top: px2vp(this.topRectHeight) + 50 })
    .justifyContent(FlexAlign.Center)
    .gesture(
      SwipeGesture({
        fingers: 1,
        direction: SwipeDirection.Vertical
      }).onAction(() => { this.isShow = false })
    )
  }

  @Builder PhoneLandscapeInfo() {
    Column({ space: 5 }) {
      Column({ space: 5 }) {
        // 歌曲封面图片
        Stack({ alignContent: Alignment.Bottom }) {
          Image(this.playmode === 0 ? this.picUrl : this.picUrl + '?param=512y512')
            .height(this.song.id == 0 ? '70%' : '100%')
            .borderRadius(5)
            .aspectRatio(1)
            .scale({ x: this.isPaused ? 0.9 : 1.0, y: this.isPaused ? 0.9 : 1.0})
            .animation({ duration: 300, curve: Curve.Smooth })
            .gesture(
              TapGesture({
                count: 2,
              }).onAction(this.handleLike)
            )
        }
        .height('80%')
        .aspectRatio(1)
      }
      .width('100%')

      // 歌曲名称&歌手
      Row({ space: 5 }) {
        Text(`${this.song.name} - ${this.artists}`)
          .textStyle(18)
          .layoutWeight(1)
          .textAlign(TextAlign.Start)
          .fontWeight(Constants.FONT_WEIGHT_BOLD)
          .onClick(() => {
            if(this.song.id !== 0 && this.playmode !== 3) {
              this.isShowArtists = true
            }
          })
          .bindSheet(this.isShowArtists, this.ArtistsSheet(), this.artistsSheetOptions)

        Column() {
          this.PersonalFmButton()
        }.scale({ x: 0.8, y: 0.8 })

        this.ToolBar(20)
      }
      .width('80%')
      .layoutWeight(1)
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    }
    .layoutWeight(1)
    .padding({ top: Constants.PADDING_EDGE_TEXT })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .gesture(
      SwipeGesture({
        fingers: 1,
        direction: SwipeDirection.Vertical
      }).onAction(() => { this.isShow = false })
    )
  }

  @Builder ControllButtons() {
    Row() {
      LoopModeButton({ imgWidth: 25, btnWidth: 25, imgColor: Color.White }).opacity(0.8)
      this.PlayButton(50)
      PlayQueueButton({ imgWidth: 25, imgColor: Color.White }).opacity(0.8)
    }
    .opacity(0.6)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
    .justifyContent(FlexAlign.SpaceBetween)
    .width('90%')
  }

  @Builder PhoneUI() {
    Column() {
      Swiper() {
        this.SongInfo()
        Column() {
          LyricComponent()
            .width('100%')
            .layoutWeight(1)
          Row({ space: 10 }) {
            Column() {
              this.PhoneLandscapeSlider('100%')
            }
            .layoutWeight(1)
            this.PlayButton(35)
          }
          .padding({ left: 5, right: Constants.PADDING_EDGE_DEFAULT })
          .opacity(0.3)
          .constraintSize({
            minWidth: 0,
            maxWidth: 500
          })
        }
        .padding({ top: px2vp(this.topRectHeight), bottom: px2vp(this.bottomRectHeight) })
      }
      .disableSwipe(this.totalOpacity === 0.5 ? false : true)
      .indicator(
        new DotIndicator()
          .top(px2vp(this.topRectHeight) + 5)
          .selectedColor(Color.White)
          .color(Color.Gray)
      )
      .clip(false)
      .loop(false)
      .layoutWeight(1)
    }
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder LargeUI() {
    Row() {
      Column({ space: 5 }) {
        Column() {
          this.SongInfo()
        }
        .width(this.deviceType === resourceManager.DeviceType.DEVICE_TYPE_TABLET ? '80%' : '90%')
        .height('100%')
      }
      .layoutWeight(1)

      LyricComponent()
        .width('100%')
        .layoutWeight(1)
    }
    .width(this.widBp === 'md' ? '100%' : '90%')
    .height('100%')
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
  }

  @Builder PhoneLandscapeUI() {
    Column() {
      Row() {
        Column() {
          this.PhoneLandscapeInfo()

          this.PhoneLandscapeSlider()

          Column() {
            Row() {
              LoopModeButton({ imgWidth: 20, btnWidth: 20, imgColor: Color.White }).opacity(0.8)
              this.PlayButton(35)
              PlayQueueButton({ imgWidth: 20, imgColor: Color.White }).opacity(0.8)
            }
            .opacity(0.6)
            .justifyContent(FlexAlign.SpaceBetween)
            .width('70%')
          }
          .width('90%')
        }
        .padding({ bottom: 5 })
        .width('100%')
        .layoutWeight(1)

        LyricComponent()
          .layoutWeight(1)
      }
      .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
  }

  @Builder SmallUI() {
    Swiper() {
      Column() {
        Row({ space: 10 }) {
          Column() {
            Column() {
              Image(this.playmode === 0 ? this.picUrl : this.picUrl + '?param=512y512')
                .aspectRatio(1)
                .width(this.song.id === 0 ? '70%' : '100%')
                .borderRadius(5)
                .scale({ x: this.isPaused ? 0.9 : 1.0, y: this.isPaused ? 0.9 : 1.0})
                .animation({ duration: 300, curve: Curve.Smooth })
                .gesture(
                  TapGesture({
                    count: 2,
                  }).onAction(this.handleLike)
                )
            }
            .width('100%')
            .height('100%')
            .layoutWeight(1)
            .justifyContent(FlexAlign.Center)

            Row() {
              Column({ space: 10 }) {
                Text(this.song.name)
                  .textStyle(16)
                  .fontWeight(FontWeight.Bold)
                Text(this.artists)
                  .textStyle(12)
                  .fontWeight(FontWeight.Bold)
              }
              .layoutWeight(1)
              Image(this.isLiked || this.playmode === PLAYMODE.LOCAL ? $r('app.media.ic_public_favor_filled') : $r('app.media.ic_public_favor'))
                .fillColor(Color.White)
                .height(20)
                .aspectRatio(1)
                .draggable(false)
                .backgroundColor(Color.Transparent)
                .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
                .onClick(this.handleLike)
            }
            .padding(Constants.PADDING_EDGE_DEFAULT)

            Row({ space: 10 }) {
              Column() {
                this.PhoneLandscapeSlider('100%')
              }
              .layoutWeight(1)
              this.PlayButton(25)
            }
            .opacity(0.3)
          }
          .layoutWeight(1)
        }
        .padding({ left: 5, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .padding({
        top: Constants.PADDING_MEDIUM,
        bottom: Constants.PADDING_EDGE_DEFAULT,
        left: Constants.PADDING_EDGE_DEFAULT,
        right: Constants.PADDING_EDGE_DEFAULT
      })

      LyricComponent()
    }
    .autoPlay(false)
    .indicator(false)
  }

  @Builder PersonalFmButton() {
    Button(this.heightBp === 'sm' ? PlayConstants.PERSONAL_FM_MODE_NAME[this.personalFmMode] : `私人FM - ${PlayConstants.PERSONAL_FM_MODE_NAME[this.personalFmMode]}`)
      .fontColor(Color.White)
      .fontSize(Constants.FONT_SIZE_COMMON)
      .backgroundColor(Color.Transparent)
      .backdropBlur(BlurStyle.Regular)
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
      .borderRadius(1)
      .shadow({ radius: 10 })
      .scale((this.widBp === 'md' && this.heightBp === 'sm') ? { centerX: 0.8, centerY: 0.8 } : { centerX: 1, centerY: 1 })
      .visibility(this.isPersonalFm && this.playmode === 1 ? Visibility.Visible : Visibility.None)
      .bindMenu(PersonalFmMenu(this.personalFmMode))
  }

  @Builder PlayerActionSheet() {
    PlayerActionSheet({
      isShow: this.isShowMenu,
      isShowTimer: this.isShowTimer,
      isShowAddSheet: this.isShowAddSheet,
      isShowArtists: this.isShowArtists,
      isShowSettings: this.isShowSettings,
      showOrientation: (this.widBp === 'md' && this.heightBp === 'sm') || (this.widBp === 'sm' && this.heightBp === 'md')
    })
  }

  @Builder ArtistsSheet() {
    ArtistsSheet({ artists: this.song.artists, isShow: this.isShowArtists, isShowCover: this.isShow })
  }

  @Builder SettingsSheet() {
    PlaySettingSinglePage()
  }
}

@Extend(Text) function textStyle(size:number) {
  .width('100%')
  .fontSize(size)
  .fontColor(Color.White)
  .maxLines(1)
  .padding({ left: 5, right: 5 })
  .textAlign(TextAlign.Start)
  .textOverflow({ overflow: TextOverflow.MARQUEE })
}

@Extend(Image) function buttonImgStyle(size: number = 50) {
  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
  .width(size)
  .fillColor(Color.White)
  .draggable(false)
}

