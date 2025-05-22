import { AppConstants } from "../constants/AppConstants"

interface Version {
  currentVersion: string
  currentVersionCode: number
  downloadUrl: string
}

interface Announcement {
  isShow: boolean
  title: string
  message: string
}

interface Data {
  Version: Version
  Announcement: Announcement
  AnnouncementAG: Announcement
  Sponsor: string[]
  SponsorCode: string
}

export interface AppInfo {
  data: Data
}

export const AppInfoClass: AppInfo = {
  data: {
    Version: {
      currentVersion: AppConstants.VERSION,
      currentVersionCode: AppConstants.VERSIONCODE,
      downloadUrl: ''
    },
    Announcement: {
      isShow: false,
      title: '',
      message: ''
    },
    AnnouncementAG: {
      isShow: false,
      title: '',
      message: ''
    },
    Sponsor: [],
    SponsorCode: ''
  }
}