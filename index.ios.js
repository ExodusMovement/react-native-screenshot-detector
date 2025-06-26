import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNScreenshotDetector } = NativeModules

const eventEmitter = new NativeEventEmitter(RNScreenshotDetector)

const SCREENSHOT_EVENT = 'ScreenshotTaken'
const SCREEN_RECORDING_EVENT = 'ScreenRecordingChanged'

const subscribe = (cb) => {
  // 감사자 지적 반영: subscribe 메서드에서도 네이티브 observer 시작
  if (RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenRecording) {
    RNScreenshotDetector.subscribeToScreenRecording()
  }
  
  const sub = eventEmitter.addListener(SCREENSHOT_EVENT, (data) => {
    cb(data)
  })
  return () => {
    sub.remove()
    
    // 감사자 지적 반영: cleanup에서도 네이티브 observer 정리
    if (RNScreenshotDetector && RNScreenshotDetector.unsubscribeFromScreenRecording) {
      RNScreenshotDetector.unsubscribeFromScreenRecording()
    }
  }
}

const subscribeToScreenRecording = (cb) => {
  if (RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenRecording) {
    RNScreenshotDetector.subscribeToScreenRecording()
  }
  
  const sub = eventEmitter.addListener(SCREEN_RECORDING_EVENT, (data) => {
    cb(data)
  })
  return () => {
    sub.remove()
    if (RNScreenshotDetector && RNScreenshotDetector.unsubscribeFromScreenRecording) {
      RNScreenshotDetector.unsubscribeFromScreenRecording()
    }
  }
}

const disableScreenshots = () => {
  if (RNScreenshotDetector && RNScreenshotDetector.disableScreenshots) {
    RNScreenshotDetector.disableScreenshots()
  }
}

const enableScreenshots = () => {
  if (RNScreenshotDetector && RNScreenshotDetector.enableScreenshots) {
    RNScreenshotDetector.enableScreenshots()
  }
}

const isScreenRecording = async () => {
  if (RNScreenshotDetector && RNScreenshotDetector.isScreenRecording) {
    try {
      const result = await RNScreenshotDetector.isScreenRecording()
      return result
    } catch (error) {
      return false
    }
  } else {
    return false
  }
}

const ScreenshotDetector = {
  subscribe,
  subscribeToScreenRecording,
  disableScreenshots,
  enableScreenshots,
  isScreenRecording,
}

export default ScreenshotDetector
