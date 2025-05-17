import mediaQuery from '@ohos.mediaquery'
import { StorageConstants } from '../../constants/StorageConstants'

class BreakpointUtils {
  private currentWdBreakpoint: string = 'sm'
  private currentHtBreakpoint: string = 'sm'
  private smListenerWD?: mediaQuery.MediaQueryListener
  private mdListenerWD?: mediaQuery.MediaQueryListener
  private lgListenerWD?: mediaQuery.MediaQueryListener
  private smListenerHT?: mediaQuery.MediaQueryListener
  private mdListenerHT?: mediaQuery.MediaQueryListener
  private lgListenerHT?: mediaQuery.MediaQueryListener

  private updateCurrentWd(breakpoint: string) {
    if (this.currentWdBreakpoint !== breakpoint) {
      this.currentWdBreakpoint = breakpoint
      AppStorage.setOrCreate(StorageConstants.BREAKPOINT_WIDTH, this.currentWdBreakpoint)
    }
  }

  private updateCurrentHt(breakpoint: string) {
    if (this.currentHtBreakpoint !== breakpoint) {
      this.currentHtBreakpoint = breakpoint
      AppStorage.setOrCreate(StorageConstants.BREAKPOINT_HEIGHT, this.currentHtBreakpoint)
    }
  }

  private isWdBreakpointSM = (mediaQueryResult: mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentWd('sm')
    }
  }
  private isWdBreakpointMD = (mediaQueryResult: mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentWd('md')
    }
  }
  private isWdBreakpointLG = (mediaQueryResult: mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentWd('lg')
    }
  }
  private isHtBreakpointSM = (mediaQueryResult: mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentHt('sm')
    }
  }
  private isHtBreakpointMD = (mediaQueryResult: mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentHt('md')
    }
  }
  private isHtBreakpointLG = (mediaQueryResult: mediaQuery.MediaQueryResult) => {
    if (mediaQueryResult.matches) {
      this.updateCurrentHt('lg')
    }
  }

  public register() {
    AppStorage.setOrCreate(StorageConstants.BREAKPOINT_WIDTH, this.currentWdBreakpoint)
    AppStorage.setOrCreate(StorageConstants.BREAKPOINT_HEIGHT, this.currentHtBreakpoint)
    this.smListenerWD = mediaQuery.matchMediaSync('(320vp<=width<600vp)')
    this.smListenerWD.on('change', this.isWdBreakpointSM)
    this.smListenerHT = mediaQuery.matchMediaSync('(320vp<=height<600vp)')
    this.smListenerHT.on('change', this.isHtBreakpointSM)
    this.mdListenerWD = mediaQuery.matchMediaSync('(600vp<=width<840vp)')
    this.mdListenerWD.on('change', this.isWdBreakpointMD)
    this.mdListenerHT = mediaQuery.matchMediaSync('(600vp<=height<840vp)')
    this.mdListenerHT.on('change', this.isHtBreakpointMD)
    this.lgListenerWD = mediaQuery.matchMediaSync('(840vp<=width)')
    this.lgListenerWD.on('change', this.isWdBreakpointLG)
    this.lgListenerHT = mediaQuery.matchMediaSync('(840vp<=height)')
    this.lgListenerHT.on('change', this.isHtBreakpointLG)
  }

  public unregister() {
    this.smListenerWD?.off('change', this.isWdBreakpointSM)
    this.mdListenerWD?.off('change', this.isWdBreakpointMD)
    this.lgListenerWD?.off('change', this.isWdBreakpointLG)
    this.smListenerHT?.off('change', this.isHtBreakpointSM)
    this.mdListenerHT?.off('change', this.isHtBreakpointMD)
    this.lgListenerHT?.off('change', this.isHtBreakpointLG)
  }

  getWidthBreakpoint(): string {
    return this.currentWdBreakpoint
  }

  getHeightBreakpoint(): string {
    return this.currentHtBreakpoint
  }
}

const breakpointUtils = new BreakpointUtils()
export default breakpointUtils as BreakpointUtils