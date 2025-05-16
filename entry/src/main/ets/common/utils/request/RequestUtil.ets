import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios'
import { LogUtil } from '@pura/harmony-utils'
import Constants from '../../constants/Constants'
import { StorageConstants } from '../../constants/StorageConstants'
import { Api } from '../../model/Api'
import { getApiUrl, getCookie } from '../../functions/common/get'
import { RealIP } from '../../model/Settings'

const TAG = 'RequestUtil'

let isLogged = AppStorage.prop<boolean>(StorageConstants.IS_LOGGED)
let baseUrl = AppStorage.prop<string>(StorageConstants.API_URL)

const instance = axios.create({
  timeout: 15000
})

instance.interceptors.request.use(async (request: InternalAxiosRequestConfig ) => {
  const settings: Api = await AppStorage.get(StorageConstants.API_SETTINGS) as Api
  if(settings.user !== 'cloudmusic' && request.params?.baseUrl != Constants.API_URL) return Promise.reject()
  // baseUrl
  request.baseURL = !request.params.baseUrl ? await getApiUrl() : request.params.baseUrl
  // timeout
  request.timeout = request.params.timeout ?? 15000
  // Cookie
  if(!request.params.noCookie) {
    const cookie = await getCookie()
    // request.params.cookie = cookie
    request.headers['cookie'] = await getCookie()
  }
  // realIP
  if(!request.url?.includes('/login')) {
    const realIP = await AppStorage.get(StorageConstants.REAL_IP) as RealIP
    if(realIP.toggle) {
      request.params.realIP = realIP.realIp
    }
  }
  return request
}, (err: AxiosError) => {
  LogUtil.error(TAG, 'request error: ' + err)
  return Promise.reject()
})

instance.interceptors.response.use((response: AxiosResponse) => {
  return response
}, (err: AxiosError) => {
  LogUtil.error(TAG, `error: ${err?.status} + ${err.message}`)
  return Promise.reject(err)
})

interface ApiResponse<T> {
  data: T
}

const commonRequest = async<T>(config: AxiosRequestConfig): Promise<T> => {
  const response = await instance.request(config) as ApiResponse<T>
  return response.data
}

export default commonRequest