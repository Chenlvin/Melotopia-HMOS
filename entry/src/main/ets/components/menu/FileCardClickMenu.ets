import { PasteboardUtil, ToastUtil, LogUtil, DialogUtil, EmitterUtil } from "@pura/harmony-utils"
import Constants from "../../common/constants/Constants"
import { EmitterConstants } from "../../common/constants/EmitterConstants"
import { LocalSong, LocalSong_INITIAL, Song } from "../../common/entities/Song"
import { fetchMetadata } from "../../common/functions/common/convert"
import { getLocalSongArtists } from "../../common/functions/common/get"
import { playQueue } from "../../common/functions/play/playControl"
import FileUtils from "../../common/utils/file/FileUtils"
import PlayQueueUtils from "../../common/utils/play/PlayQueueUtils"
import { ButtonOptions } from "@pura/harmony-utils/src/main/ets/entity/DialogOptions"
import { StorageConstants } from "../../common/constants/StorageConstants"

@Component
export struct FileCardClickMenu {
  @Prop localSong: LocalSong = LocalSong_INITIAL
  @Prop artistsString: string = ''
  @Link showMatchSheet: boolean
  @StorageLink(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  playWithList: () => void = () => {}

  private handlePlay = async (immediately: boolean = true) => {
    try {
      const rootUrl = FileUtils.getFilesDir()
      const fileUrl = rootUrl + `/${this.localSong.songFile}`
      const metadata = await fetchMetadata(fileUrl)
      let artists = await getLocalSongArtists(this.localSong.artists)
      let song: Song = {
        id: this.localSong.songId,
        name: this.localSong.name,
        artists: artists,
        album: {
          id: 0,
          name: '',
          picUrl: '',
          artists: [],
          size: 0
        },
        duration: metadata ? ((metadata.duration) ? parseInt(metadata.duration) : 0) : 0,
        alias: [],
        fee: 0
      }
      PlayQueueUtils.queueAdd(0, song, this.artistsString, this.localSong.songFile)
      if(immediately) {
        playQueue(PlayQueueUtils.currentQueueIndex + 1)
      }
    } catch (e) {
      LogUtil.error('Play local song error: ' + e.message)
      ToastUtil.showToast('播放失败')
    }
  }

  private handleListPlay = async () => {
    this.isPlayerLoading = true
    this.playWithList()
    this.isPlayerLoading = false
  }

  private handleDelete = async () => {
    DialogUtil.showPrimaryDialog({
      title: '删除文件',
      message: `确定删除 "${this.localSong.songFile}" ?`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          try {
            await FileUtils.deleteFile([this.localSong])
            EmitterUtil.post(EmitterConstants.REFRESH_LOCALSONGS, () => {})
          } catch (e) {
            ToastUtil.showToast('删除时出错')
            LogUtil.error('Delete local song error: ' + e.message)
          }
        }
      }
    })
  }

  private handleExport = () => {
    let buttons: ButtonOptions[] = [{
      value: '音频文件',
      action: () => {
        FileUtils.saveFile([this.localSong])
      }
    }]

    if(this.localSong.songId > 0) {
      buttons.push(
        {
          value: '封面',
          action: () => {
            FileUtils.saveFile([this.localSong], 'img')
          }
        },
        {
          value: '歌词',
          action: () => {
            FileUtils.saveFile([this.localSong], 'lyric')
          }
        },
        {
          value: '所有',
          fontColor: $r('app.color.app_red'),
          action: () => {
            FileUtils.saveFile([this.localSong], 'all')
          }
        }
      );
    }

    buttons.push({
      value: '取消',
      fontColor: Color.Red,
      action: () => {}
    })

    DialogUtil.showDialog({
      buttons: buttons,
      title: '导出歌曲',
      message: `${this.localSong.songFile}`
    })
  }

  build() {
    Menu() {
      MenuItem({ content: this.localSong.songFile }).width('80%')
        .onClick(() => {
          PasteboardUtil.setDataText(`${this.localSong.name}`)
          ToastUtil.showToast('已复制歌名至剪切板')
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_add_filled'), '下一首播放', $r('app.color.reverse')))
        .onClick(() => this.handlePlay(false))

      MenuItem(this.MenuItem($r('app.media.ic_public_play_norm'), '单曲播放', $r('app.color.reverse')))
        .onClick(() => this.handlePlay(true))

      MenuItem(this.MenuItem($r('app.media.ic_play_fill'), '随列表播放', $r('app.color.reverse')))
        .onClick(this.handleListPlay)

      MenuItem(this.MenuItem($r('app.media.ic_public_search_filled'), '匹配歌曲'))
        .onClick(() => {
          this.showMatchSheet = true
        })

      MenuItem(this.MenuItem($r('app.media.ic_public_folder_filled'), '导出到本机'))
        .onClick(this.handleExport)

      MenuItem(this.MenuItem($r('app.media.ic_public_delete_filled'), '删除歌曲', $r('app.color.app_red')))
        .onClick(this.handleDelete)
    }
    .constraintSize({
      minWidth: 100,
      maxWidth: 500
    })
  }

  @Builder
  MenuItem(image: ResourceStr, title: string, contentColor: string | Color | ResourceStr = $r('app.color.reverse')) {
    Row({ space: 10 }) {
      Column() {
        Image(image)
          .fillColor(contentColor)
          .width(20)
      }
      .width(22)
      Text(title)
        .fontColor(contentColor)
        .fontSize(Constants.FONT_SIZE_COMMON)
        .fontWeight(FontWeight.Medium)
    }
    .padding({ left: 15, right: 15, top: 5, bottom: 5 })
    .height(40)
  }
}