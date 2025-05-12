import { StorageConstants } from "../../common/constants/StorageConstants";
import { Album, Album_INITIAL } from "../../common/entities/Album";
import { Comment } from "../../common/entities/Comment";
import { COMMENT_TYPE } from "../../common/model/Enum";
import { CommentPage } from "../../pages/list/CommentPage";

@Component
export struct AlbumCommentSheet {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @State isLoading: boolean = true
  @State comments: Comment[] = []
  @Prop album: Album = Album_INITIAL

  build() {
    CommentPage({
      param: {
        id: this.album.id,
        name: this.album.name,
        type: COMMENT_TYPE.ALBUM
      },
      showMiniPlayer: false
    })
  }
}