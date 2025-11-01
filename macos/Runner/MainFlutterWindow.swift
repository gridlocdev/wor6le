import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
  // Load the dark mode preference from UserDefaults
  // The Flutter SharedPreferences plugin stores values in UserDefaults
  // under the app's suite using the same keys. We read the 'dark_mode'
  // key which matches the Dart StorageService.
  let defaults = UserDefaults.standard
  let darkMode = defaults.bool(forKey: "dark_mode")
    
    // Set the window background color based on stored preference
    if darkMode {
      // Dark mode background color: RGB(18, 18, 19)
      self.backgroundColor = NSColor(red: 18/255.0, green: 18/255.0, blue: 19/255.0, alpha: 1.0)
    } else {
      // Light mode background color: white
      self.backgroundColor = NSColor.white
    }
    
    // Set a minimum window size to prevent overflow
    self.minSize = NSSize(width: 500, height: 700)
    
    // Set initial window size if too small
    let initialSize = NSSize(width: max(windowFrame.width, 500), height: max(windowFrame.height, 700))
    let newFrame = NSRect(x: windowFrame.origin.x, y: windowFrame.origin.y, width: initialSize.width, height: initialSize.height)
    self.setFrame(newFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    
    // Set up method channel to listen for theme changes from Flutter
    let methodChannel = FlutterMethodChannel(
      name: "com.wor6le/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "setWindowBackgroundColor" {
        if let args = call.arguments as? [String: Any],
           let isDark = args["isDark"] as? Bool {
          DispatchQueue.main.async {
            if isDark {
              self?.backgroundColor = NSColor(red: 18/255.0, green: 18/255.0, blue: 19/255.0, alpha: 1.0)
            } else {
              self?.backgroundColor = NSColor.white
            }
          }
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }
}
