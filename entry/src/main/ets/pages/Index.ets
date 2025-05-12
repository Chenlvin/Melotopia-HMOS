import { Explore } from '../common/view/Explore'
import { BottomBarComponent } from '../components/play/BottomBarComponent';
import Constants from '../common/constants/Constants';
import {
  AlbumParam,
  ArtistParam,
  CommonParam } from '../common/model/PageParams';
import { UserLists } from '../common/view/userLists/UserLists';
import { Me } from '../common/view/Me';
import { StorageConstants } from '../common/constants/StorageConstants';
import BreakpointUtils from '../common/utils/system/BreakpointUtils';
import { EmitterUtil, LogUtil, ToastUtil } from '@pura/harmony-utils';
import { EmitterConstants } from '../common/constants/EmitterConstants';
import { PageMap } from '../common/model/PageMap';
import WindowUtils from '../common/utils/system/WindowUtils';
import { FloatLyric, FloatLyric_INITIAL } from '../common/model/Settings';
import { App } from '@kit.ArkUI';
import { lyricsPipManager } from './lyrics/PipLyrics';

@Entry
@Component
struct Index {
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = true
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) widBp: string = 'sm'
  @StorageProp(StorageConstants.DEFAULT_PAGE_INDEX) index: number = 0
  @StorageProp(StorageConstants.FLOAT_LYRIC_STYLE) floatLyric: FloatLyric = FloatLyric_INITIAL
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpointWD: string = 'sm'
  @State currentHour: number = 0
  @State tabCurrentIndex: number = 0
  @State categoryTabIndex: number = 0
  @State contentTabIndex: number = 0
  private tabController: TabsController = new TabsController()
  async aboutToAppear(): Promise<void> {
    App.setImageCacheCount(Constants.CACHE_DISK_MAX_SIZE)
    App.setImageRawDataCacheSize(Constants.CACHE_DISK_MAX_SIZE)
    BreakpointUtils.register()
    setTimeout(() => {
      this.tabCurrentIndex = this.index
    }, 1)
    // const isFirstLaunch = await PreferencesUtils.getPreferenceValue<boolean>(StorageConstants.USER_PREF, 'isFirstLaunch', true)
    // if(isFirstLaunch) {
    //   PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, 'isFirstLaunch', false)
    // }
    EmitterUtil.onSubscribe(EmitterConstants.PUSH_PAGE, <T extends ArtistParam | AlbumParam>(param: CommonParam<T>) => {
      if(!this.pageInfos.getAllPathName().includes(param.pageName)) {
        this.pageInfos.pushPathByName(param.pageName, param.param, this.pageInfos.size() === 0 && this.widBp === 'lg' ? false : true)
      } else {
        this.pageInfos.replacePath({ name: param.pageName, param: param.param }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
      }
    })
  }

  aboutToDisappear(): void {
    BreakpointUtils.unregister()
  }

  onPageShow(): void {
    this.currentHour = new Date().getHours()
    AppStorage.setOrCreate(StorageConstants.IS_IN_FOREGROUND, true)
    // if(this.floatLyric.on) WindowUtils.createLyricsFloatWindow()
    if(this.floatLyric.on) lyricsPipManager.startPip()
  }

  onPageHide(): void {
    AppStorage.setOrCreate(StorageConstants.IS_IN_FOREGROUND, false)
  }

  private getDynamicPageIndex(): number {
    return this.validApiUrl ? 1 : 0
  }

  private getMenuItems(): NavigationMenuItem[] {
    let items: NavigationMenuItem[] = []
    if(this.index !== 2) {
      items.push({
        value: 'Search',
        icon: $r('app.media.ic_public_search_filled'),
        action: () => {
          this.pageInfos.clear()
          this.pageInfos.pushPathByName('SearchPage', null, (this.widBp === 'lg') && this.pageInfos.size() === 0 ? false : true)
        }
      })
    }
    if(this.pageInfos.size() > 0 && this.breakpointWD === 'lg') {
      items.push({
        value: 'Clear',
        icon: $r('app.media.ic_public_cancel'),
        action: () => {
          this.pageInfos.clear()
        }
      })
    }
    // if(this.index === 1) {
    //   items.push({
    //     value: 'AddPlayList',
    //     icon: $r('app.media.ic_public_add_norm'),
    //     action: () => {
    //       this.addPlayListDialog.open()
    //     }
    //   })
    // }
    if(this.index === 2) {
      items.push({
        value: 'Settings',
        icon: $r('app.media.ic_public_settings'),
        action: () => {
          AppStorage.setOrCreate('isShowSettings', true)
        }
      })
    }
    return items
  }

  build() {
    Navigation(this.pageInfos) {
      Stack({ alignContent: Alignment.Bottom }) {
        Tabs({ controller: this.tabController, index: this.tabCurrentIndex }) {
          TabContent() { Explore({ currentHour: this.currentHour }) }
          if(this.validApiUrl) {
            TabContent() { UserLists({ categoryTabIndex: this.categoryTabIndex, contentTabIndex: this.contentTabIndex }) }
          }
          TabContent() { Me({ breakpoint: this.widBp }) }
        }
        .height('100%')
        .width('100%')
        .barHeight(0)
        .edgeEffect(EdgeEffect.None)
        .animationDuration(300)
        .onAnimationStart((from, target) => {
          this.index = target
        })
        .onChange((index) => { this.index = index })

        BottomBarComponent()
          .padding({
            left: Constants.PADDING_EDGE_DEFAULT,
            right: Constants.PADDING_EDGE_DEFAULT,
            bottom: Constants.PADDING_EDGE_DEFAULT + 54
          })
          .backgroundColor(Color.Transparent)
      }
    }
    .height('100%')
    .width('100%')
    .navBarWidth('50%')
    .navBarPosition(NavBarPosition.Start)
    .mode((this.widBp == 'lg' && this.pageInfos.size() > 0) ? NavigationMode.Split : NavigationMode.Stack)
    .enableModeChangeAnimation(true)
    .titleMode(NavigationTitleMode.Mini)
    .title(this.index === 1 && this.validApiUrl ? this.CategoryTabBar : this.index === 0 ? $r('app.string.Explore') : $r('app.string.Me'))
    .menus(this.getMenuItems())
    .hideBackButton(true)
    .backgroundColor($r('app.color.background'))
    .navDestination(PageMap)
    .toolbarConfiguration(this.ToolBar(), { backgroundBlurStyle: BlurStyle.Regular, barStyle: BarStyle.STACK, backgroundColor: Color.Transparent })
    .animation({ duration: 500, curve: Curve.Smooth })
  }

  @Builder ToolBar() {
    Row() {
      this.ToolBarItem(0, $r('app.media.ic_gallery_discover'), $r('app.media.ic_gallery_discover_filled'), $r('app.string.Explore'))
      if(this.validApiUrl) {
        this.ToolBarItem(1, $r('app.media.ic_public_drawer'), $r('app.media.ic_public_drawer_filled'), $r('app.string.Lists'))
      }
      this.ToolBarItem(1 + this.getDynamicPageIndex(), $r('app.media.ic_public_contacts'), $r('app.media.ic_public_contacts_filled'), $r('app.string.Me'))
    }
    .backgroundColor(Color.Transparent)
    .justifyContent(FlexAlign.SpaceEvenly)
    .width('100%')
  }

  @Builder ToolBarItem(index: number, icon: ResourceStr, activeIcon: ResourceStr, text: string | ResourceStr) {
    Column({ space: 3 }) {
      Image(this.index == index ? activeIcon : icon)
        .width(Constants.SIZE_ICON_BUTTON_BAR)
        .fillColor(this.index == index ? $r('app.color.app_red') : Color.Gray)
      Text(text)
        .fontSize(Constants.FONT_SIZE_BAR)
        .fontColor(this.index == index ? $r('app.color.app_red') : Color.Gray)
    }
    .layoutWeight(1)
    .onClick(() => {
      this.tabController.changeIndex(index)
    })
  }

  @Builder CategoryTabBar() {
    Column() {
      Row({ space: Constants.PADDING_EDGE_DEFAULT }) {
        this.CategoryBarButtonItem($r('app.string.Playlist'), 0)
        this.CategoryBarButtonItem($r('app.string.Album'), 1)
        this.CategoryBarButtonItem($r('app.string.Radio'), 2)
      }
      .backgroundColor($r('app.color.main'))
      .borderRadius(Constants.RADIUS_CARD)
      .justifyContent(FlexAlign.Center)
      .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder CategoryBarButtonItem(title: string | ResourceStr, index: number) {
    Button() {
      Text(title)
        .maxFontSize(18)
        .minFontSize(8)
        .fontColor(this.categoryTabIndex === index ? $r('app.color.app_red') : Color.Gray)
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
    }
    .width(50)
    .height(30)
    .backgroundColor(Color.Transparent)
    .padding(5)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.7 })
    .onClick(() => {
      this.contentTabIndex = this.categoryTabIndex = index
    })
  }
}