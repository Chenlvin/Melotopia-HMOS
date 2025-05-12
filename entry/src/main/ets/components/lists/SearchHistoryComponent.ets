import Constants from "../../common/constants/Constants";
import { StorageConstants } from "../../common/constants/StorageConstants";
import PreferencesUtils from "../../common/utils/data/PreferencesUtils";

@Preview
@Component
export struct SearchHistoryComponent {
  @StorageLink(StorageConstants.SEARCH_HISTORY) @Watch('updateSearchHistory') searchHistory: string[] = []
  @Link searchKeyword: string

  updateSearchHistory() {
    PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.SEARCH_HISTORY, this.searchHistory)
  }

  build() {
    Column() {
      Row() {
        Text('搜索历史')
          .width('100%')
          .fontWeight(FontWeight.Bold)
          .fontSize(Constants.FONT_SIZE_COMMON)
          .fontColor($r('app.color.reverse'))
          .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
        Image($r('app.media.ic_public_delete_filled'))
          .fillColor(Color.Gray)
          .width(Constants.FONT_SIZE_COMMON)
          .aspectRatio(1)
          .onClick(() => {
            this.searchHistory = []
          })
      }
      .justifyContent(FlexAlign.SpaceAround)
      .width('100%')
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.searchHistory, (text: string, index) => {
          this.SearchHistoryCard(text, index)
        })
      }
      .width('100%')
      .backgroundColor(Color.Transparent)
    }
    .padding({ left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT })
  }

  @Builder SearchHistoryCard(text: string, index: number) {
    Row({ space: 30 }) {
      Text(text)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontColor($r('app.color.reverse'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Start)
      Image($r('app.media.ic_public_cancel'))
        .fillColor(Color.Gray)
        .width(Constants.FONT_SIZE_COMMON)
        .aspectRatio(1)
        .onClick(() => {
          this.searchHistory.splice(index, 1)
        })
    }
    .onClick(() => {
      this.searchKeyword = text
    })
    .justifyContent(FlexAlign.SpaceAround)
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.8 })
    .constraintSize({
      minWidth: 80,
      maxWidth: 300
    })
    .padding(Constants.PADDING_EDGE_DEFAULT)
    .margin({ right: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
    .borderRadius(10)
    .backgroundColor($r('app.color.main'))
  }
}