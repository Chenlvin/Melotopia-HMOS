import Constants from "../../common/constants/Constants"
import { createPlayList } from "../../api/playListApi"
import { ToastUtil } from "@pura/harmony-utils"

@CustomDialog
export struct AddPlayListDialog {
  @State isPrivacy: boolean = false
  @State name: string = ''
  controller: CustomDialogController

  private async handleCreate() {
    if(this.name == '') {
      ToastUtil.showToast('歌单名不能为空')
    } else if(this.name.length > 40) {
      ToastUtil.showToast('歌单名长度不能超过 40')
    } else {
      await createPlayList(this.name, this.isPrivacy)
    }
  }

  build() {
    Scroll() {
      Column({ space: 30 }) {
        Text('新建歌单')
          .width('100%')
          .textAlign(TextAlign.Start)
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontWeight(FontWeight.Medium)

        TextInput({
          placeholder: '请输入歌单名'
        })
          .width('100%')
          .onChange((value) => {
             this.name = value
          })

        Button('创 建')
          .backgroundColor($r('app.color.app_red'))
          .onClick(() => {
            this.handleCreate()
          })
      }
      .padding(Constants.PADDING_EDGE_TEXT)
    }
    .width('100%')
    .constraintSize({
      maxWidth: 500,
      minHeight: 100,
      maxHeight: 800
    })
  }

}