import FileUtils from '../../common/utils/file/FileUtils';
import { FileCard } from '../../components/cards/FileCard';
import { BottomBarComponent } from '../../components/play/BottomBarComponent';
import Constants from '../../common/constants/Constants';
import { StorageConstants } from '../../common/constants/StorageConstants';
import { DialogUtil, EmitterUtil, LogUtil, ToastUtil } from '@pura/harmony-utils';
import RelationalStoreUtils from '../../common/utils/data/RelationalStoreUtils';
import { LazyData } from '@pie/lazy-data';
import { PickerUtil } from '@pura/picker_utils';
import { EmitterConstants } from '../../common/constants/EmitterConstants';
import { PlayAllButton } from '../../components/buttons/PlayAllButton';
import PlayQueueUtils from '../../common/utils/play/PlayQueueUtils';
import { LocalSong, Song } from '../../common/entities/Song';
import { getLocalSongArtists } from '../../common/functions/common/get';
import { Album_INITIAL } from '../../common/entities/Album';
import { playQueue } from '../../common/functions/play/playControl';
import { PlayQueue } from '../../common/model/PlayQueue';
import { BarLoading } from '../../components/cards/Loading';

/**
 * 缓存管理页
 * DownloadPage
 */
const TAG = 'LocalSongPage '

@Component
export struct LocalSongPage {
  @StorageProp(StorageConstants.BOTTOM_RECT_HEIGHT) bottomRectHeight: number = 0
  @StorageProp(StorageConstants.TOP_RECT_HEIGHT) topRectHeight: number = 0
  @StorageProp(StorageConstants.BREAKPOINT_WIDTH) breakpoint: string = 'sm'
  @StorageLink(StorageConstants.IS_PLAYER_LOADING) isPlayerLoading: boolean = false
  @State searchKeyword: string = ''
  @State filteredSongs: LocalSong[] = new Array()
  @State isSorted: boolean = false
  @State isSelecting: boolean = false
  @State selectedSongs: LocalSong[] = []
  @State selectedIndex: number[] = []
  @State localSongs: LocalSong[] = []
  @State isShowMigration: boolean = false
  @State dataSource: LazyData<LocalSong> = new LazyData()
  @State dataSourceFiltered: LazyData<LocalSong> = new LazyData()
  @State isLoading: boolean = false
  @Consume('pageInfos') pageInfos: NavPathStack
  private originalOrderList: LocalSong[] = []

  menus: NavigationMenuItem[] = [
    {
      value: 'Upload',
      icon: $r('app.media.ic_public_upload_filled'),
      action: () => {
        DialogUtil.showPrimaryDialog({
          title: '上传文件',
          message: '支持上传本机音频文件至本地曲库\n' +
            '支持格式为.mp3 .flac\n\n' +
            '* 文件名格式：歌手 - 歌名.flac* \n\n' +
            '文件名格式不正确会导致无法识别\n',
          primaryButton: "取消",
          secondaryButton: {
            value: '上传',
            action: () => {
              this.handleUpload()
            }
          }
        })
      }
    }
  ]

  async aboutToAppear(): Promise<void> {
    this.isLoading = true
    await this.refreshList()
    this.isLoading = false
    EmitterUtil.onSubscribe(EmitterConstants.REFRESH_LOCALSONGS, () => {
      this.refreshList()
    })
  }

  aboutToDisappear(): void {
    EmitterUtil.unSubscribe(EmitterConstants.REFRESH_LOCALSONGS)
  }

  private handlePlayAll = async (index: number = 0) => {
    let playSongs: PlayQueue[] = []
    this.isPlayerLoading = true
    for(let localSong of this.searchKeyword ? this.filteredSongs : this.localSongs) {
      try {
        let artists = await getLocalSongArtists(localSong.artists)
        let song: Song = { id: localSong.songId, name: localSong.name, artists: artists, album: Album_INITIAL,
          duration: -1, alias: [], fee: 0
        }
        playSongs.push({ playmode: 0, song: song, fileName: localSong.songFile, picUrl: '' })
      } catch (e) {
        LogUtil.error('Add LocalSong Error: ' + e.message)
      }
    }
    await PlayQueueUtils.cleanQueue()
    await PlayQueueUtils.queueAdd_array(playSongs)
    playQueue(index)
    setTimeout(() => {
      this.isPlayerLoading = false
    }, 200)
  }

  private handleSave = () => {
    DialogUtil.showDialog({
      buttons: [
        {
          value: '音频文件',
          action: () => {
            FileUtils.saveFile(this.selectedSongs, 'song')
          }
        },
        {
          value: '封面',
          action: () => {
            FileUtils.saveFile(this.selectedSongs, 'img')
          }
        },
        {
          value: '歌词',
          action: () => {
            FileUtils.saveFile(this.selectedSongs, 'lyric')
          }
        },
        {
          value: '所有',
          fontColor: $r('app.color.app_red'),
          action: () => {
            FileUtils.saveFile(this.selectedSongs, 'all')
          }
        },
        {
          value: '取消',
          fontColor: Color.Red,
          action: () => {}
        },
      ],
      title: '批量导出',
      message: `已选择 ${this.selectedSongs.length} 首歌曲`
    })
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        if(this.isLoading) {
          Column() {
            LoadingProgress()
              .width(Constants.SIZE_LOADING_PROGRESS_DEFAULT)
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.Center)
        } else {
          Column({ space: Constants.PADDING_EDGE_DEFAULT }) {
            if (this.localSongs.length > 0) {
              Row() {
                if(this.isSelecting) {
                  Text(`已选 ${this.selectedSongs.length} 项`)
                    .fontSize(Constants.FONT_SIZE_COMMON)
                    .padding({ left: Constants.PADDING_MEDIUM })
                } else if(this.isPlayerLoading) {
                  BarLoading()
                } else {
                  PlayAllButton({ count: this.searchKeyword ? this.filteredSongs.length : this.localSongs.length, clickAction: () => {
                    this.handlePlayAll(0)
                  }})
                }
                Row({ space: 20 }) {
                  if(!this.isSelecting) {
                    // Image($r('app.media.ic_files_name_drive'))
                    //   .width(Constants.SIZE_ICON_BUTTON_BAR)
                    //   .aspectRatio(1)
                    //   .fillColor(this.isSorted ? $r('app.color.blue') : Color.Gray)
                    //   .onClick(() => {
                    //     this.isSorted = !this.isSorted
                    //     if (this.searchKeyword) {
                    //       this.filteredSongs = this.getSortedList(this.filteredSongs)
                    //     }
                    //   })
                  } else {
                    if(this.selectedSongs.length > 0) {
                      Image($r('app.media.ic_public_delete'))
                        .width(Constants.SIZE_ICON_BUTTON_BAR)
                        .aspectRatio(1)
                        .fillColor(Color.Gray)
                        .onClick(() => {
                          this.handleDelete()
                        })
                      Image($r('app.media.ic_public_folder'))
                        .width(Constants.SIZE_ICON_BUTTON_BAR)
                        .aspectRatio(1)
                        .fillColor(Color.Gray)
                        .onClick(this.handleSave)
                    }
                    // CheckboxGroup({ group: 'fileCard' })
                    //   .width(Constants.SIZE_ICON_BUTTON_BAR - 5)
                    //   .height(Constants.SIZE_ICON_BUTTON_BAR - 5)
                  }
                  Image($r('app.media.ic_gallery_material_select_checkbox'))
                    .width(Constants.SIZE_ICON_BUTTON_BAR)
                    .aspectRatio(1)
                    .fillColor(this.isSelecting ? $r('app.color.blue') : Color.Gray)
                    .onClick(() => {
                      animateTo({ duration: 100, curve: Curve.EaseInOut }, () => {
                        this.isSelecting = !this.isSelecting
                        this.selectedSongs = []
                        this.selectedIndex = []
                      })
                    })
                }
                .height(30)
              }
              .height(30)
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
              .padding({ right: Constants.PADDING_EDGE_DEFAULT })
            }
            else {
              Column({ space: 20 }) {
                Text('本地文件列表为空').width('100%').textAlign(TextAlign.Center).padding({ left: 30, right: 30, top: 10 })
              }
            }

            List() {
              if(!this.searchKeyword) {
                this.ListContent(this.dataSource)
              } else {
                this.ListContent(this.dataSourceFiltered)
              }
              ListItem()
                .height(px2vp(this.bottomRectHeight) + Constants.HEIGHT_MINI)
            }
            .cachedCount(3)
            .lanes(this.breakpoint === 'sm' ? 1 : 2)
            .edgeEffect(EdgeEffect.Spring)
            .scrollBar(BarState.Off)
            .backgroundColor($r('app.color.background'))
            .height('100%')
            .width('100%')
            .layoutWeight(1)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
            .backToTop(true)
          }
          .height('100%')
          .width('100%')
        }

        BottomBarComponent()
          .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
          .backgroundColor(Color.Transparent)
          .visibility(this.breakpoint === 'lg' ? Visibility.None : Visibility.Visible)
      }
      .backgroundColor($r('app.color.background'))
      .height('100%')
    }
    .title($r('app.string.LocalSongs'))
    .menus(this.menus)
    .title(this.ToolBar)
    .backgroundColor($r('app.color.background'))
  }

  private handelSearch() {
    try {
      if (!this.searchKeyword) {
        this.dataSourceFiltered.setData([])
        return
      }
      const keyword = this.searchKeyword.trim().toLowerCase()
      this.filteredSongs = this.localSongs.filter((item: LocalSong) => {
        return item.songFile.toString().toLowerCase().includes(keyword)
      })
      this.dataSourceFiltered.setData(this.filteredSongs)
    } catch (e) {
      ToastUtil.showToast('搜索时出错')
      LogUtil.error(TAG, 'Error while handelSearch: ' + e.message)
    }
  }

  private async refreshList() {
    this.localSongs = await RelationalStoreUtils.getLocalSongs()
    this.originalOrderList = this.localSongs
    this.isSelecting = false
    this.selectedSongs = []
    this.dataSource.setData(this.localSongs)
    this.dataSource.notifyDataReload()
  }

  private async handleUpload() {
    PickerUtil.selectDocument({
      maxSelectNumber: 99,
      fileSuffixFilters: ['音频 | .mp3,.flac,.MP3,.FLAC']
    }).then((uris) => {
      FileUtils.saveFilesToDirectory(uris).then(async (result) => {
        if(result) {
          ToastUtil.showToast(`上传 ${result} 个文件`)
          await this.refreshList()
        }
      })
    })
  }

  private getSortedList(list: LocalSong[]): LocalSong[] {
    return this.isSorted ?
    [...list].sort((a, b) => a.songFile.localeCompare(b.songFile)) :
    this.originalOrderList.filter(f => list.some(l => l.songFile === f.songFile))
  }

  private handleDelete() {
    DialogUtil.showPrimaryDialog({
      title: '确认',
      message: `是否删除选中的 ${this.selectedSongs.length} 个文件?`,
      primaryButton: "取消",
      secondaryButton: {
        value: '删除',
        fontColor: Color.Red,
        action: async () => {
          await FileUtils.deleteFile(this.selectedSongs)
          setTimeout(async () => {
            await this.refreshList()
          }, 100)
        }
      }
    })
  }

  @Builder ToolBar() {
    Column() {
      Search({
        placeholder: $r('app.string.Search_content'),
        icon: '/resources/base/media/ic_public_search_filled.svg'
      })
        .id('search')
        .height(Constants.HEIGHT_SEARCH)
        .layoutWeight(1)
        .searchButton('搜索')
        .onChange((value) => {
          if(value === '') {
            this.filteredSongs = []
            this.searchKeyword = ''
          }
        })
        .onSubmit((value) => {
          this.searchKeyword = value
          this.handelSearch()
        })
    }
    .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
  }

  @Builder ListContent(dataSource: LazyData<LocalSong>) {
    LazyForEach(dataSource,
      (item: LocalSong, index: number) => {
          Row() {
            FileCard({
              localSong: item,
              listPlayAction: async() => { await this.handlePlayAll(index) }
            })
              .padding({ left: Constants.PADDING_EDGE_DEFAULT, right: Constants.PADDING_EDGE_DEFAULT })
              .layoutWeight(1)
            this.CardCheckBox(item, index)
          }
          .width('100%')
        .padding({ bottom: Constants.PADDING_EDGE_DEFAULT })
      },(item: LocalSong) => item.songFile.toString() + this.searchKeyword)
  }

  @Builder CardCheckBox(localSong: LocalSong, index: number) {
    Checkbox({ group: 'fileCard' })
      .select(this.selectedIndex.includes(this.localSongs.indexOf(localSong)))
      .shape(CheckBoxShape.ROUNDED_SQUARE)
      .width(Constants.SIZE_ICON_BUTTON_HEAD)
      .aspectRatio(1)
      .visibility(this.isSelecting ? Visibility.Visible : Visibility.None)
      .padding({ right: Constants.PADDING_EDGE_DEFAULT })
      .onChange((value) => {
        if(value) {
          this.selectedSongs.push(localSong)
          this.selectedIndex.push(this.localSongs.indexOf(localSong))
        } else {
          this.selectedSongs = this.selectedSongs.filter(songItem => songItem.name !== localSong.name)
          this.selectedIndex = this.selectedIndex.filter(songIndex => songIndex !== this.localSongs.indexOf(localSong))
        }
      })
  }
}