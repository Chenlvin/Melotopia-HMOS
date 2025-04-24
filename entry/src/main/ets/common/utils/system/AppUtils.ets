import { common } from "@kit.AbilityKit"
import { StorageConstants } from "../../constants/StorageConstants"

export const getContext_ = (): common.UIAbilityContext => {
  const context = AppStorage.get<common.UIAbilityContext>(StorageConstants.CONTEXT)
  if (!context) {
    throw new Error('Application context not initialized')
  }
  return context
}