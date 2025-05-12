import { LogUtil, ToastUtil } from "@pura/harmony-utils";
import Constants from "../common/constants/Constants";
import { StorageConstants } from "../common/constants/StorageConstants";
import { AppInfo, AppInfoClass } from "../common/entities/AppInfo";
import commonRequest from "../common/utils/request/RequestUtil";

/**
 * 获取App信息
 */
export async function getAppInfo() {
  try {
    const response = await commonRequest<AppInfo>({
      url: '/api/melotopia/app',
      params: { baseUrl: Constants.API_URL, timeout: 3000, noCookie: true }
    })
    AppStorage.setOrCreate(StorageConstants.APP_INFO, response ?? AppInfoClass)
  } catch (e) {
    LogUtil.error('get app info error: ' + e.message())
    ToastUtil.showToast('获取应用信息失败')
  }
}