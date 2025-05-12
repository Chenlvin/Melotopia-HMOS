import { ToastUtil } from '@pura/harmony-utils';
import { checkQrLogin, getQrCode } from '../../api/qrCodeApi';
import Constants from '../../common/constants/Constants';


@Component
export struct QrCodeLogin {
  @Consume('pageInfos') pageInfos: NavPathStack
  @State first: boolean = true
  @State qrCode:string[] = []

  async aboutToAppear() {
    if(this.first) {
      try {
        this.qrCode = await getQrCode()
      } catch (e) {
        ToastUtil.showToast('获取二维码出错: ' + e.message)
      } finally {
        this.first = false
      }
    } else return
  }

  build() {
    NavDestination() {
      Stack() {
        Column({ space: 20 }) {
          Column({ space: 30 }) {
            Text('请使用APP内扫码扫描下方二维码\n扫码成功后点击下方按钮获取登录信息')
              .textAlign(TextAlign.Center)
            // QR Code
            if(!this.qrCode) { Text('获取二维码出错').fontColor(Color.Red) }
            else {
              Image(this.qrCode[1]).width(256)
            }
            Button('手动获取登录状态')
              .onClick(async () => {
                await checkQrLogin(this.qrCode[0]).then((result) => {
                  if(result) {
                    ToastUtil.showToast('登录成功!')
                    this.pageInfos.pop()
                  }
                })
              })
          }
          .layoutWeight(1)
        }
      }
      .backgroundColor($r('app.color.background'))
      .height('100%')
      .width('100%')
      .padding({ top: Constants.PADDING_EDGE_TEXT })
    }
    .title('登录')
    .backgroundColor($r('app.color.background'))
  }
}