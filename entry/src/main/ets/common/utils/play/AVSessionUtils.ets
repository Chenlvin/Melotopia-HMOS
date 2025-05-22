import { avSession } from "@kit.AVSessionKit";
import { LogUtil, RandomUtil } from "@pura/harmony-utils";
import { StorageConstants } from "../../constants/StorageConstants";
import { Song, Song_INITIAL } from "../../entities/Song";
import { changeCycleMode,
  pauseMusic, playNext, playPre, resumeMusic, seekMusic } from "../../functions/play/playControl";
import { likeThisSong } from "../../functions/play/songLike";
import { getContext_ } from "../system/AppUtils";
import LyricUtils from "./LyricUtils";

/**
 * AVSession 播控中心工具类
 */
const TAG = '[AVSessionUtils] '

class AVSessionUtils {
  private instance: avSession.AVSession | null = null
  private isActivating = false
  private cycleMode: number = 0
  private currentSong: Song = Song_INITIAL
  private currentArtists: string = ''
  private currentPic: string | ResourceStr  = ''
  private lyric: string = ''
  private controller: avSession.AVSessionController | null = null

  private async getInstance(): Promise<avSession.AVSession> {
    if(!this.instance) {
      this.instance = await this.createSession()
    }
    return this.instance
  }

  async getController(): Promise<avSession.AVSessionController> {
    if(!this.controller) {
      const instance = await this.getInstance()
      this.controller = await instance.getController()
    }
    return this.controller
  }

  async createSession(): Promise<avSession.AVSession> {
    let session = await avSession.createAVSession(getContext_(), 'cloudmusic', 'audio')
    try {
      let cycleMode: number | undefined = AppStorage.get('cycleMode')
      if(cycleMode) this.cycleMode = this.cycleMode
      else this.cycleMode = 0

      session.on('play', () => {
        resumeMusic()
      });
      session.on('pause', () => {
        pauseMusic()
      });
      session.on('playNext', () => {
        playNext()
      });
      session.on('playPrevious', () => {
        playPre()
      });
      session.on('seek', (time) => {
        seekMusic(time)
      });
      session.on('toggleFavorite', (isFavor) => {
        likeThisSong().then(async () => {
          (await this.getInstance()).setAVPlaybackState({ isFavorite: this.isFavorite() })
        })
      })
      session.on('setLoopMode', (loopMode) => {
        if(loopMode == 0) { changeCycleMode(1) }
        else if(loopMode == 1) { changeCycleMode(2) }
        else if(loopMode == 2) { changeCycleMode(3) }
        else { changeCycleMode(0) }
      })

      this.controller = await session.getController()

    } catch (e) {
      LogUtil.error(TAG, '创建session失败 / create session error: ' + JSON.stringify(e))
    } finally {
      return session
    }
  }

  async sendControlCommand(command: avSession.AVControlCommand) {
    const controller = await this.getController()
    controller.sendControlCommand(command, () => {})
  }

  async setDefaultMetadata(song: Song, artists: string) {
    this.currentSong = song
    this.currentArtists = artists
    let instance = await this.getInstance()
    instance.setAVMetadata({
      assetId: `${song.id}`,
      title: song.name,
      artist: artists,
      duration: song.duration
    })
  }

  /**
   * 设置媒体信息
   * @param song
   * @param artists
   * @param picUrl
   */
  async setMetadata(song: Song, artists: string, picUrl: string) {
    this.currentSong = song
    this.currentArtists = artists
    this.currentPic = picUrl
    this.lyric = LyricUtils.lyric.lrc.lyric

    let metadata: avSession.AVMetadata = {
      assetId: `${song.id}`,
      title: song.name,
      mediaImage: picUrl.startsWith('http') ? `${picUrl}?param=256y256` : picUrl,
      artist: artists != 'null' ? artists : '未知',
      duration: song.duration,
      lyric: this.lyric
    };

    const instance = await this.getInstance()
    instance.setAVMetadata(metadata)
    let controller = await instance.getController()
  }

  /**
   * 启用
   */
  async activate() {
    if (this.isActivating) return // 防止重复调用
    try {
      const instance = await this.getInstance()
      await instance.activate()
      this.isActivating = true
    } catch (e) {
      LogUtil.error(TAG, 'Error while activating: ' + e)
      this.isActivating = false
    }
  }

  /**
   * 停用
   */
  async deactivate() {
    if (this.isActivating) return // 等待激活完成
    try {
      const instance = await this.getInstance()
      await instance.activate()
      this.isActivating = false
    } catch (e) {
      LogUtil.error(TAG, 'Error while deactivating' + e)
    }
  }

  private isFavorite(): boolean {
    const is: boolean = AppStorage.get(StorageConstants.ISLIKED) as boolean
    return is
  }

  /**
   * 设置为播放状态
   */
  async playState(time: number) {
    let loopMode = await getLoopMode()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };

    (await this.getInstance()).setAVPlaybackState(playbackState)
  }

  /**
   * 设置为暂停状态
   */
  async pauseState(time: number) {
    let loopMode = await getLoopMode()
    let pausedState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime()
      }
    };
    (await this.getInstance()).setAVPlaybackState(pausedState);
  }

  /**
   * 设置为缓冲状态
   */
  async bufferingState(time: number) {
    let loopMode = await getLoopMode()
    let playbackState: avSession.AVPlaybackState = {
      state: avSession.PlaybackState.PLAYBACK_STATE_BUFFERING,
      loopMode: loopMode,
      isFavorite: this.isFavorite(),
      position: {
        elapsedTime: time,
        updateTime: new Date().getTime(),
      }
    };
    (await this.getInstance()).setAVPlaybackState(playbackState)
  }
}

async function getLoopMode(): Promise<number> {
  let loopMode = 0
  let cycleMode: number | undefined = await AppStorage.get('cycleMode')
  if(cycleMode) {
    loopMode = cycleMode
  }
  return loopMode
}

const avSessionUtils = new AVSessionUtils()
export default avSessionUtils as AVSessionUtils