import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNScreenshotDetector } = NativeModules

const eventEmitter = new NativeEventEmitter(RNScreenshotDetector)

const SCREENSHOT_EVENT = 'ScreenshotTaken'
const SCREEN_RECORDING_EVENT = 'ScreenRecordingChanged'

const subscribe = (cb) => {
  if (RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenshotAndScreenRecording) {
    RNScreenshotDetector.subscribeToScreenshotAndScreenRecording()
  }
  
  const sub = eventEmitter.addListener(SCREENSHOT_EVENT, (data) => {
    cb(data)
  })
  return () => {
    sub.remove()
    
    if (RNScreenshotDetector && RNScreenshotDetector.unsubscribeFromScreenshotAndScreenRecording) {
      RNScreenshotDetector.unsubscribeFromScreenshotAndScreenRecording()
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
  disableScreenshots,
  enableScreenshots,
  isScreenRecording,
}

export default ScreenshotDetector
