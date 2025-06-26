import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNScreenshotDetector } = NativeModules

console.log('[TEST] RNScreenshotDetector module loaded:', !!RNScreenshotDetector)
console.log('[TEST] Available methods:', Object.keys(RNScreenshotDetector || {}))

const eventEmitter = new NativeEventEmitter(RNScreenshotDetector)

const SCREENSHOT_EVENT = 'ScreenshotTaken'
const SCREEN_RECORDING_EVENT = 'ScreenRecordingChanged'

const subscribe = (cb) => {
  console.log('[TEST] subscribe called - using NEW explicit method!')
  
  // Use the more explicit method name internally
  if (RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenshotAndScreenRecording) {
    console.log('[TEST] Calling subscribeToScreenshotAndScreenRecording')
    RNScreenshotDetector.subscribeToScreenshotAndScreenRecording()
    console.log('[TEST] SUCCESS: subscribeToScreenshotAndScreenRecording called')
  } else {
    console.log('[TEST] ERROR: subscribeToScreenshotAndScreenRecording not available!')
  }
  
  const sub = eventEmitter.addListener(SCREENSHOT_EVENT, (data) => {
    console.log('[TEST] ScreenshotTaken event received:', data)
    cb(data)
  })
  return () => {
    console.log('[TEST] Unsubscribing from screenshot events')
    sub.remove()
    
    // Use the more explicit method name internally
    if (RNScreenshotDetector && RNScreenshotDetector.unsubscribeFromScreenshotAndScreenRecording) {
      console.log('[TEST] Calling unsubscribeFromScreenshotAndScreenRecording')
      RNScreenshotDetector.unsubscribeFromScreenshotAndScreenRecording()
      console.log('[TEST] SUCCESS: unsubscribeFromScreenshotAndScreenRecording called')
    } else {
      console.log('[TEST] ERROR: unsubscribeFromScreenshotAndScreenRecording not available!')
    }
  }
}

const disableScreenshots = () => {
  console.log('[TEST] disableScreenshots called')
  if (RNScreenshotDetector && RNScreenshotDetector.disableScreenshots) {
    console.log('[TEST] Calling native disableScreenshots')
    RNScreenshotDetector.disableScreenshots()
    console.log('[TEST] SUCCESS: disableScreenshots called')
  } else {
    console.log('[TEST] ERROR: disableScreenshots not available!')
  }
}

const enableScreenshots = () => {
  console.log('[TEST] enableScreenshots called')
  if (RNScreenshotDetector && RNScreenshotDetector.enableScreenshots) {
    console.log('[TEST] Calling native enableScreenshots')
    RNScreenshotDetector.enableScreenshots()
    console.log('[TEST] SUCCESS: enableScreenshots called')
  } else {
    console.log('[TEST] ERROR: enableScreenshots not available!')
  }
}

const isScreenRecording = async () => {
  console.log('[TEST] isScreenRecording called')
  if (RNScreenshotDetector && RNScreenshotDetector.isScreenRecording) {
    try {
      const result = await RNScreenshotDetector.isScreenRecording()
      console.log('[TEST] isScreenRecording result:', result)
      return result
    } catch (error) {
      console.log('[TEST] ERROR in isScreenRecording:', error)
      return false
    }
  } else {
    console.log('[TEST] ERROR: isScreenRecording not available!')
    return false
  }
}

// Main API - only expose what's actually used externally
const ScreenshotDetector = {
  subscribe,
  disableScreenshots,
  enableScreenshots,
  isScreenRecording,
}

export default ScreenshotDetector
