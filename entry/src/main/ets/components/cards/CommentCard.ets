import Constants from "../../common/constants/Constants"
import { Comment, Comment_INITIAL } from "../../common/entities/Comment"

@Component
export struct CommentCard {
  comment: Comment = Comment_INITIAL

  build() {
    Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
      // User Information
      Row({ space: 5 }) {
        Image(this.comment.user.avatarUrl + '?param=128y128')
          .width(Constants.SIZE_IMG_AVATAR)
          .aspectRatio(1)
          .borderRadius(Constants.RADIUS_FULL)
        Text(this.comment.user.nickname)
          .layoutWeight(1)
          .width('100%')
          .fontColor($r('app.color.reverse'))
          .fontWeight(FontWeight.Medium)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .copyOption(CopyOptions.LocalDevice)
          .textSelectable(TextSelectableMode.SELECTABLE_FOCUSABLE)
        Text(`${this.comment.likedCount} 赞`)
          .fontColor(Color.Gray)
          .fontWeight(FontWeight.Medium)
          .fontSize(Constants.FONT_SIZE_BAR)
      }

      // Content
      Text(this.comment.content)
        .fontColor($r('app.color.reverse'))
        .lineHeight(25)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .width('100%')
        .copyOption(CopyOptions.LocalDevice)
        .textSelectable(TextSelectableMode.SELECTABLE_FOCUSABLE)
      //Time
      Text(this.comment.timeStr)
        .fontColor(Color.Gray)
        .fontWeight(FontWeight.Medium)
        .fontSize(Constants.FONT_SIZE_BAR)
        .width('100%')
    }
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .backgroundColor($r('app.color.main'))
    .borderRadius(Constants.RADIUS_CARD)
  }
}