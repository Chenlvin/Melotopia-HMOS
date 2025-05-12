import { EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { CommonParam, PlayListPageParam } from "../../common/model/PageParams"
import { TopListItem } from "../../common/entities/Recommend"

const cardHeight = Constants.HEIGHT_EXPLORE_LARGECARD

@Component
export struct TopListItemCard {
  @State topListItem: TopListItem = {
    id: 0,
    name: "",
    trackCount: 0,
    updateFrequency: "",
    coverImgUrl: "",
    description: "",
    playCount: 0,
    subscribedCount: 0
  }
  @Prop breakpoint: string = 'sm'

  build() {
    Column({ space: 5 }) {
      Image(this.topListItem.coverImgUrl)
        .width('100%')
        .aspectRatio(1)
        .borderRadius(Constants.RADIUS_IMG)
        .draggable(false)
    }
    .width(cardHeight)
    .aspectRatio(1)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.9 })
    .onClick(() => {
      let playlistParam: PlayListPageParam = {
        playList: {
          userId: 0,
          id: this.topListItem.id,
          name: this.topListItem.name,
          playCount: this.topListItem.playCount,
          coverImgUrl: this.topListItem.coverImgUrl,
          trackCount: this.topListItem.trackCount,
          subscribedCount: this.topListItem.subscribedCount,
          subscribed: false,
          creator: {
            userId: 0,
            nickname: '排行榜',
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
      EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
    })
  }
}