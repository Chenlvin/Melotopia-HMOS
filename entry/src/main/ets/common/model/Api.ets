export interface Api {
  domain: string
  port: number
  user: string
  password: string
  path: string
  https: boolean
}

export const Api_INITIAL: Api = {
  domain: '',
  port: 80,
  user: '',
  password: '',
  path: '',
  https: false
}