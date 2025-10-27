import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    
    // Set a minimum window size to prevent overflow
    self.minSize = NSSize(width: 500, height: 700)
    
    // Set initial window size if too small
    let initialSize = NSSize(width: max(windowFrame.width, 500), height: max(windowFrame.height, 700))
    let newFrame = NSRect(x: windowFrame.origin.x, y: windowFrame.origin.y, width: initialSize.width, height: initialSize.height)
    self.setFrame(newFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
