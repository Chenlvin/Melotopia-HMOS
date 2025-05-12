interface UserContent {
  avatarUrl: string
  nickname: string
  userId: number
  vipType: number
}

export interface Comment {
  user: UserContent
  commentId: number
  content: string
  time: number
  timeStr: string
  likedCount: number
}

interface CommentData {
  commentsTitle: string
  comments: Comment[]
}

export interface CommentResult {
  code: number
  data: CommentData
}

export const CommentResult_INITIAL: CommentResult = {
  code: 200,
  data: {
    commentsTitle: '',
    comments: []
  }
}

export const Comment_INITIAL: Comment = {
  user: {
    avatarUrl: '',
    nickname: '',
    userId: 0,
    vipType: 0
  },
  commentId: 0,
  content: '',
  time: 0,
  timeStr: '',
  likedCount: -1
}