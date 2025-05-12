import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { TopListItem } from "../../common/entities/Recommend"
import { TopListItemCard } from "../../components/cards/TopListItemCard"

@Component
export struct TopListPage {
  @StorageLink(StorageConstants.TOPLISTS) topList: Array<TopListItem> = []
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  build() {
    NavDestination() {
      Grid() {
        GridItem() {
          GridRow({ columns: {
            sm: 3,
            md: 5,
            lg: 3
          } }) {
            ForEach(this.topList, (item: TopListItem) => {
              GridCol() {
                TopListItemCard({ topListItem: item, breakpoint: this.breakpoint }).padding(Constants.PADDING_EDGE_DEFAULT)
              }
            })
          }
        }
        .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
      }
      .height('100%')
      .width('100%')
      .edgeEffect(EdgeEffect.Spring)
      .scrollBar(BarState.On)
      .rowsGap(15)
      .columnsTemplate('1fr')
      .layoutDirection(GridDirection.Column)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      .backToTop(true)
    }
    .title('排行榜')
    .backgroundColor($r('app.color.background'))
  }
}