import { LogUtil } from "@pura/harmony-utils"
import { getDjRadioList } from "../../api/djApi"
import Constants from "../../common/constants/Constants"
import { DjRadio } from "../../common/entities/DjRadio"
import { DjRadioCard } from "../cards/DjRadioCard"

/**
 * 艺术家搜索结果列表
 */
const TAG = "[SearchDjRadioList] "

@Component
export struct SearchDjRadioList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp('topRectHeight') topRectHeight: number = 0
  @State djRadios: DjRadio[] = []
  @Link @Watch('handleSearch') searchKeyword: string
  @State hasLoaded: boolean = false
  @State isLoading: boolean = false

  async aboutToAppear(): Promise<void> {
    if(this.searchKeyword) {
      await this.load()
    }
  }

  async handleSearch() {
    this.djRadios = []
    await this.load()
  }

  build() {
    if(this.isLoading == true) {
      Column() {
        LoadingProgress().width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
      }
      .padding({ bottom: px2vp(this.topRectHeight) })
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      List({ space: Constants.PADDING_EDGE_DEFAULT }) {
        ForEach(this.djRadios, (item: DjRadio) => {
          ListItem() {
            DjRadioCard({ djRadio: item })
          }
          .translate({ y: -40 })
          .animation({
            duration: 600,
            curve: Curve.LinearOutSlowIn
          })
          .translate({ y: 0 })
        })
        ListItem().height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
      }
      .translate({ y: -40 })
      .animation({
        duration: 600,
        curve: Curve.LinearOutSlowIn
      })
      .translate({ y: 0 })
      .layoutWeight(1)
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
  }

  async load(): Promise<void> {
    if(this.hasLoaded) return
    this.isLoading = true
    try {
      this.djRadios = await getDjRadioList(this.searchKeyword)
    } catch (e) {
      LogUtil.error(TAG, 'Error fetching DjRadio list: ', JSON.stringify(e))
    } finally {
      this.isLoading = false
      this.hasLoaded = true
    }
  }
}