import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNScreenshotDetector } = NativeModules
const eventEmitter = new NativeEventEmitter(RNScreenshotDetector)

const SCREENSHOT_EVENT = 'ScreenshotTaken'
const SCREEN_RECORDING_EVENT = 'ScreenRecordingChanged'

const subscribe = (cb) => {
  const sub = eventEmitter.addListener(SCREENSHOT_EVENT, (data) => {
    cb(data)
  })
  return () => {
    sub.remove()
  }
}

const subscribeToScreenRecording = (cb) => {
  if (RNScreenshotDetector.subscribeToScreenRecording) {
    RNScreenshotDetector.subscribeToScreenRecording()
  }
  
  const sub = eventEmitter.addListener(SCREEN_RECORDING_EVENT, (data) => {
    cb(data)
  })
  return () => {
    sub.remove()
    if (RNScreenshotDetector.unsubscribeFromScreenRecording) {
      RNScreenshotDetector.unsubscribeFromScreenRecording()
    }
  }
}

const disableScreenshots = () => {
  if (RNScreenshotDetector.disableScreenshots) {
    RNScreenshotDetector.disableScreenshots()
  }
}

const enableScreenshots = () => {
  if (RNScreenshotDetector.enableScreenshots) {
    RNScreenshotDetector.enableScreenshots()
  }
}

const isScreenRecording = async () => {
  if (RNScreenshotDetector.isScreenRecording) {
    return RNScreenshotDetector.isScreenRecording()
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
