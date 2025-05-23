import { VersionCard } from '../../components/settings/TextContent'
import Constants from '../../common/constants/Constants'
import { WebPageParam } from '../../common/model/PageParams'
import { CommonSettingsCard } from '../../components/cards/SettingsCard'
import { SettingsPageMap } from '../../common/model/PageMap'
import { StorageConstants } from '../../common/constants/StorageConstants'

/**
 * 设置页面
 */
@Component
export struct SettingsPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @Provide('settingsPageInfos') settingsPageInfos: NavPathStack = new NavPathStack()

  build() {
    Navigation(this.settingsPageInfos) {
      Stack() {
        Scroll() {
          Column({ space: 10 }) {
            List({ space: 10 }) {
              ListItemGroup() {
                this.PlaySettings()
              }
              .listItemGroupStyle()

              ListItemGroup() {
                this.MainSettings()
              }
              .listItemGroupStyle()

              ListItemGroup() {
                VersionCard()
                this.OtherItems()
              }
              .listItemGroupStyle()

              ListItem().height(px2vp(this.bottomRectHeight))
            }
            .scrollBar(BarState.Auto)
            .width('100%')
            .height('100%')
            .padding({ top: Constants.PADDING_EDGE_DEFAULT })
            .layoutWeight(1)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
          }
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.background'))
    .title($r('app.string.settings'))
    .mode(NavigationMode.Stack)
    .titleMode(NavigationTitleMode.Mini)
    .navDestination(SettingsPageMap)
    .padding({ top: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder PlaySettings() {
    ListItem() {
      CommonSettingsCard({
        title: $r('app.string.SET_PLAYANDLYRIC'),
        action: () => {
          this.settingsPageInfos.pushPathByName('PlaySettingsPage', null)
        }
      })
    }
    ListItem() {
      CommonSettingsCard({
        title: $r('app.string.SET_UI'),
        action: () => {
          this.settingsPageInfos.pushPathByName('UISettingsPage', null)
        }
      })
    }
  }

  @Builder MainSettings() {
    ListItem() {
      CommonSettingsCard({
        title: $r('app.string.SET_CLOUDSERVICE'),
        action: () => {
          this.settingsPageInfos.pushPathByName('ApiSetPage', null)
        }
      })
    }
    ListItem() {
      CommonSettingsCard({
        title: $r('app.string.SET_DATAANDCACHE'),
        action: () => {
          this.settingsPageInfos.pushPathByName('CacheManagePage', null)
        }
      })
    }
  }

  @Builder OtherItems() {
    CommonSettingsCard({
      title: $r('app.string.SET_FEEDBACK'),
      action: () => {
        let param: WebPageParam = {
          title: `建议与反馈`, url: 'https://www.wjx.cn/vm/PeLnYfc.aspx# '
        }
        this.settingsPageInfos.pushPathByName('WebPage', param)
      }
    })
  }
}

@Extend(ListItemGroup) function listItemGroupStyle() {
  .divider({ strokeWidth: 0.1, startMargin: 10, endMargin: 10, color: Color.Gray })
  .backgroundColor($r('app.color.main'))
  .borderRadius(Constants.RADIUS_CARD)
  .margin({ left: 20, right: 20 })
  .padding({
    left: Constants.PADDING_EDGE_DEFAULT,
    right: Constants.PADDING_EDGE_DEFAULT,
    top: Constants.PADDING_INNER_DEFAULT,
    bottom: Constants.PADDING_INNER_DEFAULT
  })
  .constraintSize({
    minHeight: 60,
    maxHeight: '100%'
  })
}

