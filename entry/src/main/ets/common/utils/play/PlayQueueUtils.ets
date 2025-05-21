import { EmitterUtil, LogUtil } from '@pura/harmony-utils'
import { EmitterConstants } from '../../constants/EmitterConstants'
import { StorageConstants } from '../../constants/StorageConstants'
import { PlayQueue } from '../../model/PlayQueue'
import { Song, Song_INITIAL } from '../../entities/Song'
import PreferencesUtils from '../data/PreferencesUtils'

/**
 * 播放列表工具
 */
const TAG = '[PlayQueueUtils] '
const pref = StorageConstants.QUEUE_PREF

class PlayQueueUtils {
  queue:Array<PlayQueue> = []
  currentQueueIndex: number = -1

  getQueueLength(): number {
    return this.queue.length
  }

  /**
   * 初始化播放列表
   */
  async init() {
    try {
      this.currentQueueIndex = -1
      let gotQueue = await PreferencesUtils.getPreferenceValue<Array<PlayQueue>>(pref, 'queue', this.queue)
      let circleMode = await PreferencesUtils.getPreferenceValue<number>(pref, 'cycleMode', 0)
      this.queue = gotQueue
      AppStorage.setOrCreate('currentQueueIndex',this.currentQueueIndex)
      AppStorage.setOrCreate('PlayQueue',this.queue)
      AppStorage.setOrCreate('cycleMode', circleMode)
    } catch (e) {
      LogUtil.error(TAG, '初始化播放列表 init playqueue error: ' + e.message())
    }
  }

  /**
   * 同步存储
   */
  private async syncQueueToStorage() {
    try {
      AppStorage.setOrCreate('PlayQueue', this.queue)
      await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
    } catch (e) {
      LogUtil.error(TAG, 'Error while syncQueueToStorage: ' + e.message)
    }
  }

  /**
   * 添加歌曲至播放列表
   */
  async queueAdd(playmode: number, song: Song, artists: string = '', fileName: string = '', picUrl: string = '') {
    try {
      this.queue.splice(this.currentQueueIndex + 1 , 0 ,{
        playmode: playmode,
        song: song,
        fileName: fileName,
        picUrl: picUrl
      })
      await this.syncQueueToStorage()
    } catch (e) {
      LogUtil.error(TAG, '添加失败 add queue element error: ' + e.message())
    }
  }

  async queueAdd_array(queue: PlayQueue[]) {
    try {
      this.queue = this.queue.concat(queue)
      AppStorage.setOrCreate('PlayQueue', this.queue)
      await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
      EmitterUtil.post(EmitterConstants.EMITTER_REFRESH_PLAYQUEUE, () => {})
    } catch (e) {
      LogUtil.error(TAG, 'Error while queueAdd_array: ' + e.message)
    }
  }

  /**
   * 从播放列表中删除指定位置歌曲
   */
  async queueDelete(index:number) {
    try {
      this.queue.splice(index,1)
      AppStorage.setOrCreate('PlayQueue',this.queue)
      await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
      if(index < this.currentQueueIndex) {
        this.setIndex(this.currentQueueIndex - 1)
      }
    } catch (e) {
      LogUtil.error(TAG, '删除失败 delete queue element error: ' + e.message())
    }
  }

  pre(): boolean {
    if(this.currentQueueIndex > 0) {
      this.setIndex(this.currentQueueIndex - 1)
      return true // true 表示有上一首歌曲，并且移动currentQueueIndex
    }
    else return false
  }

  next(): boolean {
		if(this.currentQueueIndex < (this.queue.length - 1)) {
      this.setIndex(this.currentQueueIndex + 1)
      return true
    }
    else return false
	}

  getQueueElement(index:number): PlayQueue {
    return this.queue[index]
  }

  getQueue(): Array<PlayQueue> {
    return this.queue
  }

  getCurrentSong(): Song {
    try {
      if(this.queue[this.currentQueueIndex].playmode !== 0 ) {
        return this.queue[this.currentQueueIndex].song as Song
      } else return Song_INITIAL
    } catch (e) {
      return Song_INITIAL
    }
  }

  async cleanQueue() {
    this.queue = []
    this.currentQueueIndex = -1
    AppStorage.setOrCreate('PlayQueue',this.queue)
    AppStorage.setOrCreate('currentQueueIndex',this.currentQueueIndex)
    await PreferencesUtils.putPreferenceValue(pref, 'queue', this.queue)
  }

  async setIndex(index: number) {
    this.currentQueueIndex = index
    AppStorage.setOrCreate('currentQueueIndex',this.currentQueueIndex)
  }
}

const playQueueUtils:PlayQueueUtils = new PlayQueueUtils()
export default playQueueUtils as PlayQueueUtils