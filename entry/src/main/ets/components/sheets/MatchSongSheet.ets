import { LogUtil, ToastUtil } from "@pura/harmony-utils"
import { getLyricString } from "../../api/LyricApi"
import { getSongPicUrl, searchSongs } from "../../api/songApi"
import Constants from "../../common/constants/Constants"
import { LocalSong, Song } from "../../common/entities/Song"
import { fetchSongInfo } from "../../common/functions/common/convert"
import RelationalStoreUtils from "../../common/utils/data/RelationalStoreUtils"
import FileDownloadUtils from "../../common/utils/file/FileDownloadUtils"
import LyricUtils from "../../common/utils/play/LyricUtils"
import { SongCard } from "../cards/SongCard"

@Component
export struct MatchSongSheet {
  @Link localSong: LocalSong
  @State songsList: Song[] = []
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0
  @Link showMatchSheet: boolean

  async aboutToAppear(): Promise<void> {
    const song = await fetchSongInfo(this.localSong.songFile)
    let searchResult = await searchSongs(song.name + ' ' + song.artists[0].name, 0, 10)
    this.songsList = searchResult.list
  }

  build() {
    Column() {
      Column({ space: 10 }) {
        Text(`${this.localSong.songFile}`)
          .fontSize(Constants.FONT_SIZE_TITLE)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.reverse'))
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.MARQUEE })
      }
      .padding({ top: 20, left: Constants.PADDING_EDGE_TEXT, right: Constants.PADDING_EDGE_TEXT})
      .width('100%')

      Divider().padding({ top: 20 })

      List() {
        ForEach(this.songsList, (item: Song, index) => {
          ListItem() {
            Row({ space: 5 }) {
              SongCard({ song: item, allowToArtist: false, moreVisible: false })
                .layoutWeight(1)
              Button() {
                Row() {
                  Text('匹配')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                }
                .padding({ left: 5, right: 5 })
              }
              .backgroundColor($r('app.color.app_red'))
              .padding(5)
              .onClick(() => {
                this.handleMatch(item)
              })
            }
            .width('100%')
            .padding({ right: Constants.PADDING_EDGE_DEFAULT })
          }
        })
        ListItem().height(px2vp(this.bottomRectHeight))
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    }
    .width('100%')
    .height('100%')
  }

  private async handleMatch(song: Song) {
    try {
      this.showMatchSheet = false
      const picUrl = await getSongPicUrl(song.id)
      const lyricString = await getLyricString(song.id)
      await FileDownloadUtils.download(picUrl + '?param=512y512', `${song.id}.jpg`, 'pic')
      await LyricUtils.saveLyricToFile(lyricString, `${song.id}.lrc`)
      this.localSong.songId = song.id
      this.localSong.name = song.name
      this.localSong.artists = JSON.stringify(song.artists)
      RelationalStoreUtils.updateSong(this.localSong.id, this.localSong)
      ToastUtil.showToast('写入匹配数据成功')
    } catch (e) {
      ToastUtil.showToast('匹配失败')
      LogUtil.error('handle Match Error: ' + e.message)
    }
  }
}