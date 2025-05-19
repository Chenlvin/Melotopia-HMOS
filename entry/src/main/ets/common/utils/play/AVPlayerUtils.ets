import { LogUtil } from '@pura/harmony-utils'
import ContinuousTask from './BackgroundTaskUtils'
import AVSessionUtils from './AVSessionUtils'
import { completeDo, playQueue } from '../../functions/play/playControl'
import LyricUtils from './LyricUtils'
import { audio } from '@kit.AudioKit'
import { StorageConstants } from '../../constants/StorageConstants'
import { media } from '@kit.MediaKit'
import { BusinessError } from '@kit.BasicServicesKit'
import PlayQueueUtils from './PlayQueueUtils'
import BackgroundTaskUtils from './BackgroundTaskUtils'

const TAG = '[AVPlayerUtils] '

class AVPlayerUtils {
  private avPlayer: media.AVPlayer | null = null
  private updateAvSession: number = 0
  private audioManager = audio.getAudioManager()
  private audioSessionManager: audio.AudioSessionManager = this.audioManager.getSessionManager()
  private updateFlag: boolean = false
  private isSeeking: boolean = false
  private errorFlag: boolean = false
  private pauseFlag: boolean = false
  private lastErrorTime: number = 0

  getCurrentTime() {
    return this.avPlayer!.currentTime
  }

  async init() {
    this.isSeeking = false
    this.updateFlag = false
    if (!this.avPlayer) {
      this.avPlayer = await media.createAVPlayer()
      this.setCallback(this.avPlayer)
    }
    return this.avPlayer
  }

  async reset() {
    await this.avPlayer?.reset()
  }

  async release() {
    await this.avPlayer?.release()
    this.avPlayer?.off('error')
    this.avPlayer?.off('stateChange')
    this.avPlayer?.off('timeUpdate')
    this.avPlayer?.off('audioOutputDeviceChangeWithInfo')
    this.avPlayer?.off('audioInterrupt')
    this.avPlayer?.off('seekDone')
  }

  async setUrl(url: string) {
    const avPlayer = await this.init()
    await avPlayer.reset()
    if(avPlayer.state === 'idle') {
      avPlayer.url = url
    }
  }

  async setFdSrc(url: media.AVFileDescriptor) {
    const avPlayer = await this.init()
    avPlayer.fdSrc = url
  }

  async play() {
    const avPlayer = await this.init()
    try {
      await this.setAudioSession()
      LyricUtils.startInterval()
      avPlayer.play()
      this.pauseFlag = false
      // this.updateAvSession = setInterval(() => {
      //   if (avPlayer.state === 'playing') {
      //     AVSessionUtils.playState(avPlayer.currentTime)
      //   }
      // }, 1000)
      avPlayer.on('timeUpdate', (time: number) => {
        if(this.updateFlag) {
          this.updateFlag = false
          AVSessionUtils.playState(avPlayer.currentTime)
          setTimeout(() => {
            AVSessionUtils.playState(avPlayer.currentTime)
          }, 1000)
        } else {
          AppStorage.setOrCreate(StorageConstants.PLAY_TIME, time)
        }
      })
    } catch (e) {
      LogUtil.error(TAG, '播放错误: ' + e.message)
    }
  }

  async stop() {
    const avPlayer = await this.init()
    AVSessionUtils.pauseState(avPlayer.currentTime)
    this.clearInterval()
    avPlayer.stop()
    AVSessionUtils.deactivate()
    ContinuousTask.stopBackgroundTask()
  }

  async pause() {
    const avPlayer = await this.init()
    this.clearInterval()
    avPlayer.pause()
  }

  async seek(time: number) {
    if(this.isSeeking === true) return
    const avPlayer = await this.init()
    this.isSeeking = true
    this.updateFlag = true
    AppStorage.setOrCreate(StorageConstants.PLAY_TIME, time)
    AVSessionUtils.bufferingState(time)
    avPlayer.seek(time)
    avPlayer.play()
  }

  async syncSessionState() {
    const avPlayer = await this.init()
    if(avPlayer.state === 'playing') {
      AVSessionUtils.playState(avPlayer.currentTime)
    } else if(avPlayer.state === 'paused') {
      AVSessionUtils.pauseState(avPlayer.currentTime)
    }
  }

  private clearInterval() {
    clearInterval(this.updateAvSession)
    LyricUtils.endInterval()
  }

  private setCallback(avPlayer: media.AVPlayer) {
    avPlayer.on('error', (err: BusinessError) => {
      LogUtil.error(TAG, `Invoke avPlayer failed, code is ${err.code}, message is ${err.message}`)
      if(avPlayer.state === 'paused' || avPlayer.state === 'stopped') return

      const currentTime = Date.now()
      if (currentTime - this.lastErrorTime < 3000) {
        return
      }

      this.lastErrorTime = currentTime
      if (!this.errorFlag) {
        this.errorFlag = true
        setTimeout(() => {
          playQueue(PlayQueueUtils.currentQueueIndex)
          this.errorFlag = false
        }, 3000)
      }
    })
    avPlayer.on('audioOutputDeviceChangeWithInfo', async(changeInfo: audio.AudioStreamDeviceChangeInfo) => {
      if (changeInfo.changeReason == audio.AudioStreamDeviceChangeReason.REASON_OLD_DEVICE_UNAVAILABLE) {
        this.pause()
      }
    })
    avPlayer.on('audioInterrupt', async(interruptEvent: audio.InterruptEvent) => {
      if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_FORCE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_PAUSE:
            this.pause()
            this.pauseFlag = true
            break
          case audio.InterruptHint.INTERRUPT_HINT_STOP:
            this.pause()
            this.pauseFlag = true
            break
          default:
            break
        }
      } else if (interruptEvent.forceType === audio.InterruptForceType.INTERRUPT_SHARE) {
        switch (interruptEvent.hintType) {
          case audio.InterruptHint.INTERRUPT_HINT_RESUME:
            if(this.pauseFlag) this.play()
            break
          default:
            break
        }
      }
    })
    avPlayer.on('seekDone', () => {
      this.isSeeking = false
    })
    avPlayer.on('stateChange', async (state: string) => {
      switch (state) {
        case 'idle':
          this.clearInterval()
          AVSessionUtils.deactivate()
          break
        case 'initialized':
          avPlayer.audioRendererInfo = {
            usage: audio.StreamUsage.STREAM_USAGE_MUSIC,
            rendererFlags: 0
          }
          avPlayer.prepare()
          break
        case 'prepared':
          this.play()
          break
        case 'playing':
          BackgroundTaskUtils.startTask()
          AppStorage.setOrCreate(StorageConstants.IS_PLAYING, true)
          AppStorage.setOrCreate(StorageConstants.IS_PAUSED, false)
          LyricUtils.startInterval()
          AVSessionUtils.playState(avPlayer.currentTime)
          break
        case 'paused':
          this.clearInterval()
          AppStorage.setOrCreate(StorageConstants.IS_PAUSED, true)
          AVSessionUtils.pauseState(avPlayer.currentTime)
          break
        case 'completed':
          this.clearInterval()
          AVSessionUtils.pauseState(avPlayer.currentTime)
          avPlayer.reset()
          AppStorage.setOrCreate(StorageConstants.IS_PAUSED, true)
          completeDo()
          break
        case 'stopped':
          this.clearInterval()
          ContinuousTask.stopBackgroundTask()
      }
    })
  }

  async setAudioSession() {
    const isMixWithOthers = await AppStorage.get(StorageConstants.MIX_WITH_OTHERS) as boolean
    const strategy: audio.AudioSessionStrategy = {
      concurrencyMode: isMixWithOthers ?
      audio.AudioConcurrencyMode.CONCURRENCY_MIX_WITH_OTHERS :
      audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT
    }
    await this.audioSessionManager.activateAudioSession(strategy)
  }
}

const avPlayerUtils = new AVPlayerUtils()
export default avPlayerUtils as AVPlayerUtils
