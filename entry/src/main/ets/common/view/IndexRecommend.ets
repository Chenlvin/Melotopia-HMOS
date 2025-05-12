import { DateUtil, ToastUtil } from "@pura/harmony-utils"
import { setHeartMode } from "../../api/songApi"
import { IndexCard } from "../../components/cards/IndexCard"
import Constants from "../constants/Constants"
import { StorageConstants } from "../constants/StorageConstants"
import { PlayList } from "../entities/PlayList"
import { playNext, playQueue } from "../functions/play/playControl"
import PlayQueueUtils from "../utils/play/PlayQueueUtils"

interface item {
  imgUrl: string | ResourceStr
  wid?: number
  title: string | ResourceStr
  desc: string | ResourceStr
  action: () => void
}

@Component
export struct IndexRecommend {
  @Consume('pageInfos') pageInfos: NavPathStack
  @Prop isLogged: boolean
  @StorageProp(StorageConstants.USER_PLAYLISTS) playLists: PlayList[] = []
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageProp(StorageConstants.VALID_API_URL) validApiUrl: boolean = true
  @StorageLink(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false

  private dailyAction = () => {
    if(this.pageInfos.size() === 0) {
      this.pageInfos.pushPathByName('DailyListPage', null, this.breakpoint === 'lg' ? false : true)
    } else {
      this.pageInfos.replacePathByName('DailyListPage', null)
    }
  }

  private fmAction = async () => {
    if(!this.isPlayerLoading) {
      this.isPlayerLoading = true
      try {
        AppStorage.setOrCreate(StorageConstants.IS_PERSONAL_FM, true)
        await PlayQueueUtils.cleanQueue()
        ToastUtil.showToast('开始播放私人FM')
        playNext()
      } catch (e) {
        ToastUtil.showToast('获取私人FM曲目失败')
      } finally {
        setTimeout(() => {
          this.isPlayerLoading = false
        }, 1000)
      }
    } else {
      ToastUtil.showToast('正在加载, 请稍后')
    }
  }

  private cloudAction = () => {
    if(this.isLogged) {
      if(!this.pageInfos.getAllPathName().includes('CloudPage')) {
        this.pageInfos.pushPathByName('CloudPage', null, this.pageInfos.size() === 0 && this.breakpoint === 'lg' ? false : true)
      } else {
        this.pageInfos.replacePath({ name: 'CloudPage', param: null }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
      }
    } else {
      ToastUtil.showToast('请登录后再试')
    }
  }

  private heartModeAction = async () => {
    if(this.isLogged) {
      if(!this.isPlayerLoading) {
        try {
          this.isPlayerLoading = true
          ToastUtil.showToast('开始播放心动歌单')
          await setHeartMode(PlayQueueUtils.getCurrentSong().id, this.playLists[0].id)
          playQueue(0)
        } catch (e) {
          ToastUtil.showToast('获取心动歌单失败: ' + e.message)
        } finally {
          setTimeout(() => {
            this.isPlayerLoading = false
          }, 1000)
        }
      } else {
        ToastUtil.showToast('正在加载, 请稍后')
      }
    } else {
      ToastUtil.showToast('请登录后再试')
    }
  }

  private localSongAction = () => {
    if(this.pageInfos.size() === 0) {
      this.pageInfos.pushPathByName('LocalSongPage', null, this.breakpoint === 'lg' ? false : true)
    } else {
      this.pageInfos.replacePath({ name: 'LocalSongPage', param: null }, { launchMode: LaunchMode.MOVE_TO_TOP_SINGLETON })
    }
  }

  private items: item[] = [
    {
      imgUrl: $r('app.media.index_calendar'),
      title: $r('app.string.Daily_recommend'),
      wid: 30,
      desc: DateUtil.getTodayStr('yyyy-MM-dd'),
      action: this.dailyAction
    },
    {
      imgUrl: $r('app.media.index_cloud'),
      title: $r('app.string.Cloud'),
      desc: '享受云端乐库',
      action: this.cloudAction
    },
    {
      imgUrl: $r('app.media.index_radio'),
      wid: 40,
      title: $r('app.string.Personal_fm'),
      desc: '探索多种曲风',
      action: this.fmAction
    },
    {
      imgUrl: $r('app.media.index_heart'),
      title: $r('app.string.Heart_list'),
      desc: '智能播放',
      action: this.heartModeAction
    },
    {
      imgUrl: $r('app.media.index_local'),
      title: $r('app.string.LocalSongs'),
      desc: '支持上传本机音频',
      action: this.localSongAction
    },
  ]

  private getItems(): item[] {
    return this.validApiUrl ? this.items : this.items.slice(-1)
  }

  build() {
    List({ space: Constants.PADDING_EDGE_DEFAULT }) {
      ListItem().width(10)

      ForEach(this.getItems(), (item: item, index) => {
        IndexCard({
          imgUrl: item.imgUrl,
          wid: item?.wid,
          title: item.title,
          desc: item.desc,
          clickAction: item.action
        })
      })

      ListItem().width(10)
    }
    .padding({ top: Constants.PADDING_EDGE_DEFAULT, bottom: Constants.PADDING_EDGE_DEFAULT })
    .width('100%')
    .scrollBar(BarState.Off)
    .listDirection(Axis.Horizontal)
  }
}