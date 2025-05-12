import Constants from "../../common/constants/Constants"
import { StorageConstants } from "../../common/constants/StorageConstants"
import { DjRadio, DjRadio_INITIAL, RecommendDjRadio, RecommendDjRadio_INITIAL } from "../../common/entities/DjRadio"
import { DjRadioParam } from "../../common/model/PageParams"

const recommendCoverHeight: number = Constants.HEIGHT_EXPLORE_LARGECARD
const recommendCardHeight: number = recommendCoverHeight + 30

@Component
export struct DjRadioCard {
  djRadio: DjRadio = DjRadio_INITIAL
  @Prop breakpoint: string = 'sm'
  @Consume('pageInfos') pageInfos: NavPathStack

  build() {
    Button() {
      Row({ space:15 }) {
        Image(`${this.djRadio.picUrl}?param=256y256`)
          .width(50)
          .borderRadius(Constants.RADIUS_IMG)
        Column({ space: 8 }) {
          Text(this.djRadio.name)
            .fontSize(Constants.FONT_SIZE_COMMON)
            .fontWeight(FontWeight.Medium)
            .alignSelf(ItemAlign.Start)
            .fontColor($r('app.color.reverse'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(60)
    }
    .backgroundColor(Color.Transparent)
    .borderRadius(5)
    .type(ButtonType.Normal)
    .width('100%')
    .height(60)
    .padding({ left: 20, right: 20 })
    .onClick(() => {
      let param: DjRadioParam = {
        djRadio: this.djRadio
      }
      if(!this.pageInfos.getAllPathName().includes('DjRadioPage')) {
        this.pageInfos.pushPathByName('DjRadioPage', param, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
      } else {
        this.pageInfos.replacePath({ name: 'DjRadioPage', param: param }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
      }
    })
  }
}

@Component
export struct DjRadioRecommendCard {
  djRadio: RecommendDjRadio = RecommendDjRadio_INITIAL
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'

  build() {
    Column({ space: 5 }) {
      Stack() {
        Image(this.djRadio.picUrl + '?param=256y256')
          .width('100%')
          .borderRadius(Constants.RADIUS_IMG)
      }
      .width(recommendCoverHeight)
      .aspectRatio(1)
      Text(this.djRadio.name)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor($r('app.color.reverse'))
        .fontWeight(FontWeight.Bold)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .width(recommendCoverHeight)
    }
    .height(recommendCardHeight)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      const param: DjRadioParam = {
        djRadio: {
          dj: this.djRadio.dj,
          category: this.djRadio.category,
          secondCategory: '',
          buyed: this.djRadio.buyed,
          lastProgramName: '',
          intervenePicUrl: '',
          subCount: -1,
          programCount: -1,
          picUrl: this.djRadio.picUrl,
          lastProgramId: -1,
          desc: '',
          name: this.djRadio.name,
          id: this.djRadio.id
        }
      }
      if(!this.pageInfos.getAllPathName().includes('DjRadioPage')) {
        this.pageInfos.pushPathByName('DjRadioPage', param, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
      } else {
        this.pageInfos.replacePath({ name: 'DjRadioPage', param: param }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
      }
    })
  }
}