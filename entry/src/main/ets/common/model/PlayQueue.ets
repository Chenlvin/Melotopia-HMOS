import { PLAYMODE } from "./Enum"
import { Song } from "../entities/Song"

export interface PlayQueue {
  playmode: PLAYMODE
  song: Song
  fileName: string
  picUrl: string
}