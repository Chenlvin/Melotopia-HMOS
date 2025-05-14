import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { StorageConstants } from "../common/constants/StorageConstants"
import { extractCookie } from "../common/functions/common/convert"
import commonRequest from "../common/utils/request/RequestUtil"
import { getLoginStatus } from "./loginApi"

interface GetQrCodeImg {
  qrimg: string
}

interface GetQrCodeKey {
  unikey: string
}

interface GetQrCodeResponse {
  data: GetQrCodeKey
}

interface GetQrCodeImgResponse {
  data: GetQrCodeImg
}

/**
 * 获取登录二维码
 * @returns string - qrImg
 */
export const getQrCode = async(): Promise<string[]> => {
  const keyResponse = await commonRequest<GetQrCodeResponse>({
    url: '/login/qr/key',
    params: { noCookie: true, timestamp: new Date().getTime() }
  })

  const unikey = keyResponse.data.unikey

  const imgResponse = await commonRequest<GetQrCodeImgResponse>({
    url: '/login/qr/create',
    params: { key: unikey, qrimg: true, timestamp: new Date().getTime(), noCookie: true }
  })

  return [unikey, imgResponse.data.qrimg]
}

/**
 * 检查二维码登录状态
 */
interface CheckQrResponse {
  code: number
  message: string
  cookie: string
}
export const checkQrLogin = async (key: string): Promise<boolean> => {
  const response = await commonRequest<CheckQrResponse>({
    url: '/login/qr/check',
    params: { key, noCookie: true, timestamp: new Date().getTime() }
  })
  if(response.code === 803) { // success
    let cookie = response.cookie
    if(cookie) {
      cookie = extractCookie(cookie)
      cookie = cookie + '; OS=pc'
      AppStorage.setOrCreate(StorageConstants.COOKIE, cookie)
      const result = await getLoginStatus(cookie)
      return result
    }
  }
  ToastUtil.showToast(response.message)
  return false
}