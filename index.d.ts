export interface ScreenshotDetector {
  subscribe: (callback: () => void) => () => void;
  subscribeToScreenRecording: (
    callback: (isRecording: boolean) => void
  ) => () => void;
  disableScreenshots: () => void;
  enableScreenshots: () => void;
  isScreenRecording: () => Promise<boolean>;
}

declare const ScreenshotDetector: ScreenshotDetector;

export default ScreenshotDetector;
