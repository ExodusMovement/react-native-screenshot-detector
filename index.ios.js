import { NativeEventEmitter, NativeModules, requireNativeComponent, findNodeHandle } from 'react-native'
import React, { forwardRef, useImperativeHandle, useRef } from 'react'

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
  const sub = eventEmitter.addListener(SCREEN_RECORDING_EVENT, (data) => {
    cb(data)
  })
  return () => {
    sub.remove()
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

const isScreenRecording = () => {
  if (RNScreenshotDetector.isScreenRecording) {
    return RNScreenshotDetector.isScreenRecording()
  } else {
    return Promise.resolve(false)
  }
}

const RNSecureViewNative = requireNativeComponent('RNSecureView')

const SecureView = forwardRef(({ enabled = true, children, ...props }, ref) => {
  const viewRef = useRef(null)

  useImperativeHandle(ref, () => ({
    enableProtection: () => {
      const reactTag = findNodeHandle(viewRef.current)
      if (reactTag && NativeModules.RNSecureView) {
        NativeModules.RNSecureView.enableProtection(reactTag)
      }
    },
    disableProtection: () => {
      const reactTag = findNodeHandle(viewRef.current)
      if (reactTag && NativeModules.RNSecureView) {
        NativeModules.RNSecureView.disableProtection(reactTag)
      }
    },
  }))

  return React.createElement(RNSecureViewNative, {
    ref: viewRef,
    enabled: enabled,
    ...props
  }, children)
})

SecureView.displayName = 'SecureView'

const ScreenshotDetector = {
  subscribe,
  subscribeToScreenRecording,
  disableScreenshots,
  enableScreenshots,
  isScreenRecording,
  SecureView, 
}

export default ScreenshotDetector
export { SecureView }
