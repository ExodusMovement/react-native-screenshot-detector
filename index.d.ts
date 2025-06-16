import { ViewProps } from "react-native";
import React from "react";

export interface SecureViewProps extends ViewProps {
  /**
   * Whether the secure protection is enabled
   * When true, this view will appear as black in screenshots
   * @default true
   */
  enabled?: boolean;

  /**
   * Children components to be protected
   */
  children?: React.ReactNode;
}

export interface SecureViewRef {
  enableProtection: () => void;
  disableProtection: () => void;
}

export declare const SecureView: React.ForwardRefExoticComponent<
  SecureViewProps & React.RefAttributes<SecureViewRef>
>;

export interface ScreenshotDetector {
  subscribe: (callback: () => void) => () => void;
  subscribeToScreenRecording: (
    callback: (isRecording: boolean) => void
  ) => () => void;
  disableScreenshots: () => void;
  enableScreenshots: () => void;
  isScreenRecording: () => Promise<boolean>;
  SecureView: typeof SecureView;
}

declare const ScreenshotDetector: ScreenshotDetector;

export default ScreenshotDetector;
