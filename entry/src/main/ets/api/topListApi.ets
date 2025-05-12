import { StorageConstants } from "../common/constants/StorageConstants"
import { TopList, TopListItem } from "../common/entities/Recommend"
import PreferencesUtils from "../common/utils/data/PreferencesUtils"
import commonRequest from "../common/utils/request/RequestUtil"

/**
 * 排行榜
 */
export const getTopList = async (): Promise<TopListItem[]> => {
  const response = await commonRequest<TopList>({
    url: '/toplist',
    params: {}
  })
  if(response.code === 200) PreferencesUtils.putPreferenceValue(StorageConstants.USER_PREF, StorageConstants.TOPLISTS, response.list)
  return response.list
}