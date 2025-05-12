import { PlayList } from "../../common/entities/PlayList"
import { PlayList_INITIAL } from "../../common/entities/PlayList"
import { PlayListPageParam } from "../../common/model/PageParams"
import Constants from "../../common/constants/Constants"

@Component
export struct PlayListCard {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State isShowHeart: boolean = true
  @Prop breakpoint: string = 'sm'
  playList: PlayList = PlayList_INITIAL

  build() {
    Button() {
      Row({ space:15 }) {
        Image(`${this.playList.coverImgUrl}?param=256y256`)
          .width(50)
          .borderRadius(Constants.RADIUS_IMG)
        Column({ space: 8 }) {
          Text(this.playList.name).textStyle(16).fontWeight(FontWeight.Medium)
          Text(`歌单 · ${this.playList.trackCount} 首 · ${this.playList?.creator?.nickname}`).textStyle(12).fontColor(Color.Gray)
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
      let param: PlayListPageParam = {
        playList: this.playList,
        isShowHeart: this.isShowHeart,
        useTimestamp: true
      }
      if(!this.pageInfos.getAllPathName().includes('PlayListPage')) {
        this.pageInfos.pushPathByName('PlayListPage', param, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
      } else {
        this.pageInfos.replacePath({ name: 'PlayListPage', param: param }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
      }
    })
  }
}

@Extend(Text) function textStyle(size:number) {
  .fontSize(size)
  .alignSelf(ItemAlign.Start)
  .fontColor($r('app.color.reverse'))
  .maxLines(1)
  .textOverflow({ overflow: TextOverflow.Ellipsis })
}



