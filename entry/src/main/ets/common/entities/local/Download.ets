import { Song } from "../song/Song";
import { SongDownloadItem } from "../song/SongDownload";

export interface DownloadItem {
  song: Song
  downloadItem: SongDownloadItem
}