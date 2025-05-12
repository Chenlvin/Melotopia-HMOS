import Constants from "../../common/constants/Constants"
import { ArtistParam } from "../../common/model/PageParams"
import { Artist } from "../../common/entities/Song"

@Component
export struct ArtistsSheet {
  @State artists: Artist[] = []
  @Link isShow: boolean
  @Link isShowCover: boolean
  @Consume('pageInfos') pageInfos: NavPathStack
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0

  build() {
    List({ space: 10 }) {
      ListItem() {
        Text('艺术家')
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontWeight(FontWeight.Bold)
          .width('100%')
      }
      ForEach(this.artists, (item: Artist) => {
        ListItem() {
          this.ArtistCard(item)
        }
      })
    }
    .width('100%')
    .scrollBar(BarState.Off)
    .padding({
      left: Constants.PADDING_EDGE_TEXT,
      right: Constants.PADDING_EDGE_TEXT,
      top: Constants.PADDING_EDGE_TEXT,
      bottom: px2vp(this.bottomRectHeight) * 2
    })
  }

  @Builder ArtistCard(artist: Artist) {
    Button() {
      Row({ space: 15}) {
        Image($r('app.media.ic_user_portrait'))
          .width(Constants.FONT_SIZE_TITLE)
          .fillColor($r('app.color.reverse'))
          .aspectRatio(1)
          .draggable(false)

        Text(artist.name)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .fontColor($r('app.color.reverse'))
          .width('100%')
          .layoutWeight(1)
      }
      .width('100%')
      // .padding({
      //   left: Constants.PADDING_EDGE_DEFAULT,
      //   right: Constants.PADDING_EDGE_DEFAULT,
      //   top: 5,
      //   bottom: 5
      // })
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .backgroundColor(Color.Transparent)
    .onClick(() => {
      if(artist.id !== 0 && artist.id !== -1) {
        const param: ArtistParam = {
          artist: artist
        }
        this.pageInfos.removeByName('ArtistPage')
        this.pageInfos.pushPathByName('ArtistPage', param, true)
        this.isShow = false
        this.isShowCover = false
      }
    })
  }
}