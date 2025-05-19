import { BusinessError } from '@kit.BasicServicesKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { WantAgent, wantAgent } from '@kit.AbilityKit';
import { getContext_ } from '../system/AppUtils';

/**
 * 长时任务
 */
const TAG = 'BackgroundTaskUtils '

class BackgroundTaskUtils {
  async startTask(modeType: number = 0) {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: "cn.chenlvin.melotopia.hm",
          abilityName: "EntryAbility"
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
      let bgModes: string[] = modeType === 0 ? ["audioPlayback"] : ["audioPlayback", "dataTransfer"]
      backgroundTaskManager.startBackgroundRunning(
        getContext_(),
        bgModes,
        wantAgentObj
      )
        .then(() => {
      })
        .catch((err: BusinessError) => {
        // LogUtil.error(TAG, `启动长时任务 Start Background Running 失败：Code - ${err.code}, Message - ${err.message}`)
      })
    })
  }

  async stopBackgroundTask() {
    backgroundTaskManager.stopBackgroundRunning(getContext_()).then(() => {
    }).catch((err: BusinessError) => {
      // LogUtil.error(TAG, `结束长时任务 Stop Background Running 失败：Code - ${err.code}, Message - ${err.message}`);
    })
  }
}

const conTask = new BackgroundTaskUtils()
export default conTask as BackgroundTaskUtils