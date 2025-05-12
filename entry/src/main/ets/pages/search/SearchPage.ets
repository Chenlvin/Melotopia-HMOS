import { ToastUtil } from '@pura/harmony-utils';
import { BottomBarComponent } from '../../components/play/BottomBarComponent';
import { SearchPlayListsList } from '../../components/lists/SearchPlayListsList';
import { SearchSongsList } from '../../components/lists/SearchSongsList';
import Constants from '../../common/constants/Constants';
import { StorageConstants } from '../../common/constants/StorageConstants';
import { SearchHistoryComponent } from '../../components/lists/SearchHistoryComponent';
import { SearchArtistsList } from '../../components/lists/SearchArtistsList';
import { SearchDjRadioList } from '../../components/lists/SearchDjRadioList';
import { SearchAlbumList } from '../../components/lists/SearchAlbumList';

/**
 * 歌曲列表页（搜索结果）
 */
@Component
export struct SearchPage {
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageLink(StorageConstants.SEARCH_HISTORY) searchHistory: string[] = []
  @State tabPageIndex: number = 0
  @State keyword: string = ''
  @State @Watch('syncKeyword') searchKeyword: string = ''
  private tabsController: TabsController = new TabsController()
  private searchController: SearchController = new SearchController()

  syncKeyword() {
    this.keyword = this.searchKeyword
    this.tabPageIndex = 0
    this.tabsController.changeIndex(0)
    this.searchController.stopEditing()
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Stack({ alignContent: Alignment.Top }) {
          if(this.searchKeyword != '') {
            Column({ space: 10 }) {
              this.TabBar()
              Tabs({ index: this.tabPageIndex }) {
                TabContent() { SearchSongsList({ searchKeyword: this.searchKeyword })}
                TabContent() { SearchPlayListsList({ searchKeyword: this.searchKeyword })}
                TabContent() { SearchArtistsList({ searchKeyword: this.keyword })}
                TabContent() { SearchAlbumList({ searchKeyword: this.keyword })}
                TabContent() { SearchDjRadioList({ searchKeyword: this.keyword })}
              }
              .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
              .scrollable(false)
              .layoutWeight(1)
              .onChange((index) => {
                this.tabPageIndex = index
              })
              .scrollable(true)
              .barHeight(0)
            }
            .height('100%')
            .width('100%')
          }
          else {
            SearchHistoryComponent({ searchKeyword: this.searchKeyword })
          }
        }
        .height('100%')

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.background'))
    }
    .backgroundColor($r('app.color.background'))
    .title(this.Head())
  }

  /**
   * TabBar
   */
  @Builder
  TabBarButton(content: string, toIndex: number) {
    Column() {
      Text(content)
        .fontColor(this.tabPageIndex == toIndex ? '#ffee6f6f' : $r('app.color.reverse'))
        .fontWeight(FontWeight.Bold)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .margin({ bottom: 5 })
      Divider()
        .width(Constants.FONT_SIZE_TITLE)
        .strokeWidth(3)
        .borderRadius(Constants.RADIUS_CARD)
        .color($r('app.color.app_red'))
        .opacity(this.tabPageIndex === toIndex ? 1 : 0)
        .animation({ duration: 300, curve: Curve.Smooth })
    }
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 5 })
    .backgroundColor(Color.Transparent)
    .animation({ duration: 200 })
    .onClick(() => {
      this.tabPageIndex = toIndex
    })
  }

  @Builder
  TabBar() {
    Row({ space: 5 }) {
      this.TabBarButton('单曲', 0)
      this.TabBarButton('歌单', 1)
      this.TabBarButton('艺术家', 2)
      this.TabBarButton('专辑', 3)
      this.TabBarButton('播客', 4)
    }
    .width('80%')
    .justifyContent(FlexAlign.SpaceAround)
  }

  @Builder
  Head() {
    Column() {
      Search({
        placeholder: $r('app.string.Search_content'),
        value: this.keyword,
        icon: '/resources/base/media/ic_public_search_filled.svg',
        controller: this.searchController
      })
        .defaultFocus(true)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if(!value) {
            this.searchKeyword = ''
          }
        })
        .onSubmit(async (value) => {
          if (!value) {
            ToastUtil.showToast('请输入搜索内容')
          } else {
            this.searchKeyword = value
            this.searchHistory = this.searchHistory.filter((item) => item !== value)
            this.searchHistory.unshift(value)
            this.tabPageIndex = 0
          }
        })
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT })
  }
}