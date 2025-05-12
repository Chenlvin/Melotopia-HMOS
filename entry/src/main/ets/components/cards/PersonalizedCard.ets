import { EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { CommonParam, PlayListPageParam } from "../../common/model/PageParams"
import { PersonalListItem } from "../../common/entities/Recommend"

@Component
export struct PersonalizedCard {
  @State item: PersonalListItem = {
    id: 0,
    type: 0,
    name: "",
    copywriter: "",
    picUrl: "",
    playCount: 0,
    trackCount: 0
  }

  private clickAction = () => {
    let playlistParam: PlayListPageParam = {
      playList: {
        userId: 0,
        id: this.item.id,
        name: this.item.name,
        playCount: this.item.playCount,
        coverImgUrl: this.item.picUrl,
        trackCount: this.item.trackCount,
        subscribedCount: 0,
        subscribed: false,
        creator: {
          userId: 0,
          nickname: '推荐歌单',
          avatarUrl: ''
        },
        description: ''
      },
      isShowHeart: false,
      useTimestamp: false
    }
    let param: CommonParam<PlayListPageParam> = {
      pageName: 'PlayListPage',
      param: playlistParam,
      remove: true
    }
    setTimeout(() => {
      EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
    }, 200)
  }

  build() {
    Row({ space: 10 }) {
      Image(this.item.picUrl)
        .aspectRatio(1)
        .height(80)
        .borderRadius(Constants.RADIUS_IMG)

      Column({ space: 5 }) {
        Text(this.item.name)
          .fontColor($r('app.color.reverse'))
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .width('100%')
          .textAlign(TextAlign.Start)
          .lineHeight(22)
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        if(this.item.copywriter) {
          Text(this.item.copywriter)
            .reasonText()
        }
      }
      .height(80)
      .layoutWeight(1)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .width(250)
    .clickEffect({ level: ClickEffectLevel.HEAVY, scale: 0.9 })
    .onClick(this.clickAction)
  }
}

@Extend(Text) function reasonText() {
  .alignSelf(ItemAlign.Start)
  .fontColor('#ffff3232')
  .fontSize(10)
  .padding(2)
  .backgroundColor('#ffffd2d2')
  .borderRadius(5)
}