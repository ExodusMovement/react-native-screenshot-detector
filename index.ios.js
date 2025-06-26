import { NativeEventEmitter, NativeModules } from 'react-native'

const { RNScreenshotDetector } = NativeModules

console.log('[RNScreenshotDetector] Native module loaded:', !!RNScreenshotDetector)
console.log('[RNScreenshotDetector] Available methods:', Object.keys(RNScreenshotDetector || {}))

const eventEmitter = new NativeEventEmitter(RNScreenshotDetector)

const SCREENSHOT_EVENT = 'ScreenshotTaken'
const SCREEN_RECORDING_EVENT = 'ScreenRecordingChanged'

const subscribe = (cb) => {
  console.log('[RNScreenshotDetector] subscribe called - FIXED: Now calling native observer as per audit feedback!')
  
  // ✅ 감사자 지적 반영: subscribe 메서드에서도 네이티브 observer 시작
  if (RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenRecording) {
    console.log('[RNScreenshotDetector] CALLING native subscribeToScreenRecording from subscribe method')
    try {
      RNScreenshotDetector.subscribeToScreenRecording()
      console.log('[RNScreenshotDetector] SUCCESS: subscribeToScreenRecording called from subscribe')
    } catch (error) {
      console.log('[RNScreenshotDetector] ERROR calling subscribeToScreenRecording:', error)
    }
  } else {
    console.log('[RNScreenshotDetector] subscribeToScreenRecording method not available in subscribe')
  }
  
  const sub = eventEmitter.addListener(SCREENSHOT_EVENT, (data) => {
    console.log('[RNScreenshotDetector] ScreenshotTaken event received:', data)
    cb(data)
  })
  return () => {
    console.log('[RNScreenshotDetector] Unsubscribing from screenshot events')
    
    // ✅ 감사자 지적 반영: cleanup에서도 네이티브 observer 정리
    if (RNScreenshotDetector && RNScreenshotDetector.unsubscribeFromScreenRecording) {
      console.log('[RNScreenshotDetector] CALLING native unsubscribeFromScreenRecording from subscribe cleanup')
      try {
        RNScreenshotDetector.unsubscribeFromScreenRecording()
        console.log('[RNScreenshotDetector] SUCCESS: unsubscribeFromScreenRecording called from subscribe cleanup')
      } catch (error) {
        console.log('[RNScreenshotDetector] ERROR calling unsubscribeFromScreenRecording:', error)
      }
    }
    
    sub.remove()
  }
}

const subscribeToScreenRecording = (cb) => {
  console.log('[RNScreenshotDetector] subscribeToScreenRecording called')
  console.log('[RNScreenshotDetector] RNScreenshotDetector exists:', !!RNScreenshotDetector)
  console.log('[RNScreenshotDetector] subscribeToScreenRecording method exists:', !!(RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenRecording))
  
  if (RNScreenshotDetector && RNScreenshotDetector.subscribeToScreenRecording) {
    console.log('[RNScreenshotDetector] Calling native subscribeToScreenRecording')
    try {
      RNScreenshotDetector.subscribeToScreenRecording()
      console.log('[RNScreenshotDetector] SUCCESS: Native subscribeToScreenRecording called')
    } catch (error) {
      console.log('[RNScreenshotDetector] ERROR calling native subscribeToScreenRecording:', error)
    }
  } else {
    console.log('[RNScreenshotDetector] Native subscribeToScreenRecording method not available')
  }
  
  const sub = eventEmitter.addListener(SCREEN_RECORDING_EVENT, (data) => {
    console.log('[RNScreenshotDetector] ScreenRecordingChanged event received:', data)
    cb(data)
  })
  return () => {
    console.log('[RNScreenshotDetector] Unsubscribing from screen recording events')
    sub.remove()
    if (RNScreenshotDetector && RNScreenshotDetector.unsubscribeFromScreenRecording) {
      console.log('[RNScreenshotDetector] Calling native unsubscribeFromScreenRecording')
      try {
        RNScreenshotDetector.unsubscribeFromScreenRecording()
        console.log('[RNScreenshotDetector] SUCCESS: Native unsubscribeFromScreenRecording called')
      } catch (error) {
        console.log('[RNScreenshotDetector] ERROR calling native unsubscribeFromScreenRecording:', error)
      }
    }
  }
}

const disableScreenshots = () => {
  console.log('[RNScreenshotDetector] disableScreenshots called')
  console.log('[RNScreenshotDetector] RNScreenshotDetector exists:', !!RNScreenshotDetector)
  console.log('[RNScreenshotDetector] disableScreenshots method exists:', !!(RNScreenshotDetector && RNScreenshotDetector.disableScreenshots))
  
  if (RNScreenshotDetector && RNScreenshotDetector.disableScreenshots) {
    console.log('[RNScreenshotDetector] Calling native disableScreenshots')
    try {
      RNScreenshotDetector.disableScreenshots()
      console.log('[RNScreenshotDetector] SUCCESS: Native disableScreenshots called')
    } catch (error) {
      console.log('[RNScreenshotDetector] ERROR calling native disableScreenshots:', error)
    }
  } else {
    console.log('[RNScreenshotDetector] Native disableScreenshots method not available')
  }
}

const enableScreenshots = () => {
  console.log('[RNScreenshotDetector] enableScreenshots called')
  console.log('[RNScreenshotDetector] RNScreenshotDetector exists:', !!RNScreenshotDetector)
  console.log('[RNScreenshotDetector] enableScreenshots method exists:', !!(RNScreenshotDetector && RNScreenshotDetector.enableScreenshots))
  
  if (RNScreenshotDetector && RNScreenshotDetector.enableScreenshots) {
    console.log('[RNScreenshotDetector] Calling native enableScreenshots')
    try {
      RNScreenshotDetector.enableScreenshots()
      console.log('[RNScreenshotDetector] SUCCESS: Native enableScreenshots called')
    } catch (error) {
      console.log('[RNScreenshotDetector] ERROR calling native enableScreenshots:', error)
    }
  } else {
    console.log('[RNScreenshotDetector] Native enableScreenshots method not available')
  }
}

const isScreenRecording = async () => {
  console.log('[RNScreenshotDetector] isScreenRecording called')
  console.log('[RNScreenshotDetector] RNScreenshotDetector exists:', !!RNScreenshotDetector)
  console.log('[RNScreenshotDetector] isScreenRecording method exists:', !!(RNScreenshotDetector && RNScreenshotDetector.isScreenRecording))
  
  if (RNScreenshotDetector && RNScreenshotDetector.isScreenRecording) {
    try {
      const result = await RNScreenshotDetector.isScreenRecording()
      console.log('[RNScreenshotDetector] isScreenRecording result:', result)
      return result
    } catch (error) {
      console.log('[RNScreenshotDetector] ERROR calling isScreenRecording:', error)
      return false
    }
  } else {
    console.log('[RNScreenshotDetector] Native isScreenRecording method not available')
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
