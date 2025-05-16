import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import { getDjSublist } from "../../../api/djApi";
import Constants from "../../constants/Constants";
import { StorageConstants } from "../../constants/StorageConstants";
import { DjRadioParam } from "../../model/PageParams";
import { DjRadioCard } from "../../../components/cards/DjRadioCard";
import { PlayListSkeleton } from "../../../components/skeleton/Skeleton";
import { DjRadio } from "../../entities/DjRadio";

@Component
export struct UserDjRadioList {
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @StorageProp(StorageConstants.USER_DJRADIO_LIST) djRadioList: DjRadio[] = []
  @StorageProp(StorageConstants.IS_LOGGED) @Watch('getRadioList') isLogged: boolean = false
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @State isLoading: boolean = false
  @State isRefreshing: boolean = false
  @State lastRefreshTime: number = 0
  @Consume('pageInfos') pageInfos: NavPathStack
  private refreshCooldown: number = 5000

  async aboutToAppear(): Promise<void> {
    try {
      await this.getRadioList()
    } catch (e) {
      LogUtil.error('获取歌单列表失败')
    } finally {
      this.isLoading = false
    }
  }

  private async getRadioList() {
    if(this.isLogged && this.djRadioList.length == 0) {
      this.isLoading = true
      const result = await getDjSublist()
      this.djRadioList = result.djRadios
      this.isLoading = false
    }
    else return
  }

  private async refreshContent() {
    if (!this.isLogged) return
    this.isRefreshing = true
    const currentTime = new Date().getTime()
    if (currentTime - this.lastRefreshTime < this.refreshCooldown) {
      ToastUtil.showToast('操作过于频繁，请5秒后再试')
    } else {
      try {
        const result = await getDjSublist()
        this.djRadioList = []
        this.djRadioList = result.djRadios
        this.lastRefreshTime = currentTime
        ToastUtil.showToast('刷新成功')
      } catch (e) {
      }
    }
    this.isRefreshing = false
  }

  build() {
    Refresh({ refreshing: this.isRefreshing}) {
      List() {
        if(this.isLoading) {
          this.Loading()
        }
        else {
          ForEach(this.djRadioList, (item: DjRadio, index) => {
            DjRadioCard({
              breakpoint: this.breakpoint,
              djRadio: item
            })
              .onClick(() => {
                const param: DjRadioParam = {
                  djRadio: item
                }
                if(!this.pageInfos.getAllPathName().includes('DjRadioPage')) {
                  this.pageInfos.pushPathByName('DjRadioPage', param, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
                } else {
                  this.pageInfos.replacePath({ name: 'DjRadioPage', param: param }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
                }
              })
          })
        }
        ListItem()
        ListItem().height(px2vp(this.bottomRectHeight) + 56 + Constants.HEIGHT_MINI + Constants.PADDING_EDGE_DEFAULT)
      }
      .lanes(this.breakpoint == 'lg' || this.breakpoint === 'md' ? 2 : 1)
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
    }
    .visibility(this.isLogged ? Visibility.Visible : Visibility.None)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onRefreshing(async () => {
      await this.refreshContent()
    })
  }

  @Builder
  Loading() {
    ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9, 10], () => {
      PlayListSkeleton()
    })
  }
}