import { EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { AlbumParam, CommonParam } from "../../common/model/PageParams"
import { Album, Album_INITIAL } from "../../common/entities/Album"

@Component
export struct AlbumCard {
  album: Album = Album_INITIAL
  @Prop breakpoint: string = 'sm'

  build() {
    Button() {
      Row({ space: 15 }) {
        Image(`${this.album.picUrl}?param=256y256`)
          .width(50)
          .borderRadius(Constants.RADIUS_IMG)
        Text(this.album.name)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.reverse'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
          .height('100%')
        Text(`${this.album.size} 首`)
          .fontSize(Constants.FONT_SIZE_BAR)
          .fontColor(Color.Gray)
          .fontWeight(FontWeight.Medium)
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
      let param: CommonParam<AlbumParam> = { pageName: 'AlbumPage', param: {
        album: this.album
      }, remove: true }
      EmitterUtil.post(EmitterConstants.PUSH_PAGE, param)
    })
  }
}