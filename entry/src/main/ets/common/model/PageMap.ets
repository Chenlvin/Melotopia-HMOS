import { AlbumPage } from "../../pages/art/AlbumPage"
import { ArtistPage } from "../../pages/art/ArtistPage"
import { CommentPage } from "../../pages/list/CommentPage"
import { TopListPage } from "../../pages/list/TopListPage"
import { DebugPage } from "../../pages/local/DebugPage"
import { LocalSongPage } from "../../pages/local/LocalSongPage"
import { LoginPage } from "../../pages/login/LoginPage"
import { QrCodeLogin } from "../../pages/login/QrCodeLogin"
import { WebLogin } from "../../pages/login/WebLogin"
import { CloudPage } from "../../pages/playlist/CloudPage"
import { DailyListPage } from "../../pages/playlist/DailyListPage"
import { DjRadioPage } from "../../pages/playlist/DjRadioPage"
import { PlayListPage } from "../../pages/playlist/PlayListPage"
import { SearchPage } from "../../pages/search/SearchPage"
import { AboutPage } from "../../pages/settings/AboutPage"
import { ApiSetPage } from "../../pages/settings/ApiSetPage"
import { CacheManagePage } from "../../pages/settings/CacheManagePage"
import { DonatePage } from "../../pages/settings/DonatePage"
import { FloatLyricPage } from "../../pages/settings/FloatLyricPage"
import { PlaySettingsPage } from "../../pages/settings/PlaySettingsPage"
import { SettingsPage } from "../../pages/settings/SettingsPage"
import { UISettingsPage } from "../../pages/settings/UISettingsPage"
import { WebPage } from "../../pages/web/WebPage"
import {
  AlbumParam,
  ArtistParam,
  CommentParam,
  DjRadioParam,
  PlayListPageParam,
  WebPageParam } from "./PageParams"

@Builder
export function PageMap(name: string, param: Object) {
  if(name === 'SettingsPage') {
    SettingsPage()
  }
  else if(name === 'LocalSongPage') {
    LocalSongPage()
  }
  else if(name === 'CloudPage') {
    CloudPage()
  }
  else if(name === 'DailyListPage') {
    DailyListPage()
  }
  else if(name === 'SearchPage') {
    SearchPage()
  }
  else if(name === 'PlayListPage') {
    PlayListPage({ param: param as PlayListPageParam })
  }
  else if(name === 'ArtistPage') {
    ArtistPage({ param: param as ArtistParam })
  }
  else if(name === 'AlbumPage') {
    AlbumPage({ param: param as AlbumParam })
  }
  else if(name === 'DjRadioPage') {
    DjRadioPage({ param: param as DjRadioParam })
  }
  else if(name === 'CommentPage') {
    CommentPage({ param: param as CommentParam })
  }
  else if(name === 'LoginPage') {
    LoginPage()
  }
  else if(name === 'QrCodeLogin') {
    QrCodeLogin()
  }
  else if(name === 'WebLogin') {
    WebLogin()
  }
  else if(name === 'WebPage') {
    WebPage({ param: param as WebPageParam })
  }
  else if(name == 'TopListPage') {
    TopListPage()
  }
  else if(name == 'DebugPage') {
    DebugPage()
  }
}

@Builder
export function SettingsPageMap(name: string, param: Object) {
  if(name === 'PlaySettingsPage') {
    PlaySettingsPage()
  }
  else if(name === 'UISettingsPage') {
    UISettingsPage()
  }
  else if(name === 'FloatLyricPage') {
    FloatLyricPage()
  }
  else if(name === 'ApiSetPage') {
    ApiSetPage()
  }
  else if(name === 'CacheManagePage') {
    CacheManagePage()
  }
  else if(name === 'WebPage') {
    WebPage({ param: param as WebPageParam })
  }
  else if(name === 'AboutPage') {
    AboutPage()
  }
  else if(name === 'DonatePage') {
    DonatePage()
  }
  else if(name === 'DebugPage') {
    DebugPage()
  }
}

@Builder
export function PlaySettingsPageMap(name: string, param: Object) {
  if(name === 'FloatLyricPage') {
    FloatLyricPage()
  }
}