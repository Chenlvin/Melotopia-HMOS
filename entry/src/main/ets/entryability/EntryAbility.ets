import { AbilityConstant, bundle, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { App, window } from '@kit.ArkUI';
import PreferencesUtils from '../common/utils/data/PreferencesUtils';
import { AppUtil, CrashUtil, LogUtil } from '@pura/harmony-utils';
import { appInit } from '../common/functions/app/appInit';
import { StorageConstants } from '../common/constants/StorageConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import OrientationUtils from '../common/utils/system/WindowUtils';
import Constants from '../common/constants/Constants';


export default class EntryAbility extends UIAbility {
  private uiContext?: UIContext
  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    // 初始化 Log
    LogUtil.init(0x1010, 'Melotopia', true)
    const bundleName = this.context.applicationInfo.name
    AppStorage.setOrCreate(StorageConstants.CONTEXT, this.context)
    AppStorage.setOrCreate(StorageConstants.BUNDLE_NAME, bundleName)
    CrashUtil.onHandled(() => {})
    App.setImageCacheCount(Constants.CACHE_IMAGE_MAX_COUNT)
    App.setImageRawDataCacheSize(Constants.CACHE_DISK_MAX_SIZE)
    // 初始化用户首选项
    await Promise.all([
      PreferencesUtils.loadPreference(this.context, StorageConstants.USER_PREF),
      PreferencesUtils.loadPreference(this.context, StorageConstants.SET_PERF),
      PreferencesUtils.loadPreference(this.context, StorageConstants.QUEUE_PREF)
    ])
    // 初始化应用信息
    await appInit()
  }

  onDestroy(): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
    CrashUtil.onDestroy()
    // window.findWindow(Constants.FLOAT_LYRICS_WIN_NAME)?.destroyWindow();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    AppUtil.init(this.context)
    AppStorage.setOrCreate(StorageConstants.WINDOW_STATUS_TYPE, windowStage.getMainWindowSync().getWindowStatus())

    windowStage.getMainWindow((err: BusinessError, data) => {
      const errCode: number = err.code
      if(errCode) {
        LogUtil.error('EntryAbility ', `Failed to obtain the main window.`)
        return
      }
      data.on('windowStatusChange', (windowType: window.WindowStatusType) => {
        AppStorage.setOrCreate(StorageConstants.WINDOW_STATUS_TYPE, windowType)
      })
    })

    windowStage.loadContent('pages/Index', async (err, data) => {
      if (err.code) {
        return
      }
      let windowClass: window.Window = windowStage.getMainWindowSync()
      OrientationUtils.init(windowClass)

      // 获取布局避让遮挡的区域
      let type = window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR
      let avoidArea = windowClass.getWindowAvoidArea(type)
      let bottomRectHeight = avoidArea.bottomRect.height
      AppStorage.setOrCreate(StorageConstants.BOTTOM_RECT_HEIGHT, bottomRectHeight)
      type = window.AvoidAreaType.TYPE_SYSTEM
      avoidArea = windowClass.getWindowAvoidArea(type)
      let topRectHeight = avoidArea.topRect.height
      AppStorage.setOrCreate(StorageConstants.TOP_RECT_HEIGHT, topRectHeight)

      // 注册监听函数，动态获取避让区域数据
      windowClass.on('avoidAreaChange', (data) => {
        if (data.type === window.AvoidAreaType.TYPE_SYSTEM) {
          let topRectHeight = data.area.topRect.height
          AppStorage.setOrCreate(StorageConstants.TOP_RECT_HEIGHT, topRectHeight)
        } else if (data.type == window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          let bottomRectHeight = data.area.bottomRect.height
          AppStorage.setOrCreate(StorageConstants.BOTTOM_RECT_HEIGHT, bottomRectHeight)
        }
      })
    })
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
