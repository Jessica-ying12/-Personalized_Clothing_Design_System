// src/types/naive-ui.d.ts
import 'naive-ui'

declare module 'naive-ui' {
  interface TabPaneSlots {
    tab?: () => VNode[]
  }
}
