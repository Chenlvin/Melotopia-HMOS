import Constants from "../../common/constants/Constants"
import { ArtistParam } from "../../common/model/PageParams"
import { ArtistItem } from "../../common/entities/Artists"

@Component
export struct ArtistCard {
  @Consume('pageInfos') pageInfos: NavPathStack

  artistItem: ArtistItem = {
    id: 0,
    name: "",
    picUrl: ""
  }

  build() {
    Button() {
      Row({ space: 10 }) {
        Image(this.artistItem.picUrl + '?param=256y256')
          .width(Constants.SIZE_IMG_CARD)
          .aspectRatio(1)
          .borderRadius(Constants.RADIUS_IMG)
        Text(this.artistItem.name)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.reverse'))
        .layoutWeight(1)
      }
      .padding({ left: 20, right: 20 })
    }
    .type(ButtonType.Normal)
    .backgroundColor(Color.Transparent)
    .borderRadius(10)
    .width('100%')
    .height(60)
    .onClick(() => {
      const param: ArtistParam = {
        artist: {
          id: this.artistItem.id,
          name: this.artistItem.name
        }
      }
      this.pageInfos.pushPathByName('ArtistPage', param)
    })
  }
}