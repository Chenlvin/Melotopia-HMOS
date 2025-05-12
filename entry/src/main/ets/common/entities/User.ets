interface Profile {
  userId:number
  nickname:string
  avatarUrl:string
  backgroundUrl:string
  gender:number
}

interface Account {
  id:number
  userName:string
  vipType:number
}

interface Data {
  account:Account
  profile:Profile
}

export interface User {
  data:Data
}

export const User_INITIAL: User = {
  data: {
    account: {
      id: 0,
      userName: '',
      vipType: 0
    },
    profile: {
      userId: 0,
      nickname: '',
      avatarUrl: '',
      backgroundUrl: '',
      gender: 0
    }
  }
};

