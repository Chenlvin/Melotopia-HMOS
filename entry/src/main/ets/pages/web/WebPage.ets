import { webview } from '@kit.ArkWeb';
import { WebPageParam } from '../../common/model/PageParams';

@Component
export struct WebPage {
  controller: webview.WebviewController = new webview.WebviewController()
  @State param: WebPageParam = {
    title: '',
    url: ''
  }
  menus: NavigationMenuItem[] = [
    {
      value: 'back',
      icon: $r('app.media.ic_public_back'),
      action: () => {
        this.controller.backward()
      }
    },
    {
      value: 'refresh',
      icon: $r('app.media.ic_public_refresh'),
      action: () => {
        this.controller.refresh()
      }
    }
  ]

  build() {
    NavDestination() {
      Column() {
        Web({ src: this.param.url, controller: this.controller })
          .allowWindowOpenMethod(true)
          .horizontalScrollBarAccess(true)
          .verticalScrollBarAccess(true)
          .fileAccess(true)
          .domStorageAccess(true)
          .javaScriptAccess(true)
          .imageAccess(true)
          .onlineImageAccess(true)
          .width('100%')
          .layoutWeight(1)
          .darkMode(WebDarkMode.Auto)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
      }
      .layoutWeight(1)
      .height('100%')
      .width('100%')
    }
    .height('100%')
    .title(this.param.title)
    .menus(this.menus)
    .backgroundColor($r('app.color.background'))
  }
}