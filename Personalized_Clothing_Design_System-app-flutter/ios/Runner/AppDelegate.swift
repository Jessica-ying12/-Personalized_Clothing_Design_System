import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, DCUniMPSDKEngineDelegate {

    private var sdkInitialized = false

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "UniMP_mini_apps",
            binaryMessenger: controller.binaryMessenger
        )

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            switch call.method {
            case "open":
                self.handleOpen(call: call, result: result, launchOptions: launchOptions)
            case "close":
                self.handleClose(call: call, result: result)
            case "install":
                self.handleInstall(call: call, result: result)
            case "checkExists":
                self.handleCheckExists(call: call, result: result)
            case "getVersion":
                self.handleGetVersion(call: call, result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - SDK Initialization

    private func initSDKIfNeeded(launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard !sdkInitialized else { return }
        let options = NSMutableDictionary(dictionary: launchOptions ?? [:])
        #if DEBUG
        options.setValue(NSNumber(value: true), forKey: "debug")
        #endif
        DCUniMPSDKEngine.initSDKEnvironment(launchOptions: options as! [AnyHashable: Any])
        DCUniMPSDKEngine.setDelegate(self)
        sdkInitialized = true
    }

    // MARK: - MethodChannel Handlers

    private func handleOpen(call: FlutterMethodCall, result: @escaping FlutterResult, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String, !appId.isEmpty else {
            result(FlutterError(code: "INVALID_ARGS", message: "appId is required", details: nil))
            return
        }

        initSDKIfNeeded(launchOptions: launchOptions)
        installBundledWgtIfNeeded(appId: appId)

        let configuration = DCUniMPConfiguration()
        configuration.enableBackground = true

        DCUniMPSDKEngine.openUniMP(appId, configuration: configuration) { instance, error in
            if instance != nil {
                result(true)
            } else {
                result(FlutterError(code: "OPEN_FAILED", message: error?.localizedDescription ?? "Unknown error", details: nil))
            }
        }
    }

    private func handleClose(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let _ = args["appId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "appId is required", details: nil))
            return
        }
        DCUniMPSDKEngine.closeUniMP()
        result(true)
    }

    private func handleInstall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String,
              let wgtPath = args["wgtPath"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "appId and wgtPath are required", details: nil))
            return
        }

        initSDKIfNeeded(launchOptions: nil)

        do {
            try DCUniMPSDKEngine.installUniMPResource(withAppid: appId, resourceFilePath: wgtPath, password: nil)
            result(true)
        } catch {
            result(FlutterError(code: "INSTALL_FAILED", message: error.localizedDescription, details: nil))
        }
    }

    private func handleCheckExists(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String, !appId.isEmpty else {
            result(FlutterError(code: "INVALID_ARGS", message: "appId is required", details: nil))
            return
        }

        initSDKIfNeeded(launchOptions: nil)
        result(DCUniMPSDKEngine.isExistsUniMP(appId))
    }

    private func handleGetVersion(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String, !appId.isEmpty else {
            result(FlutterError(code: "INVALID_ARGS", message: "appId is required", details: nil))
            return
        }

        initSDKIfNeeded(launchOptions: nil)

        if DCUniMPSDKEngine.isExistsUniMP(appId),
           let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appId) {
            result(version)
        } else {
            result(nil)
        }
    }

    // MARK: - Resource Helpers

    private func installBundledWgtIfNeeded(appId: String) {
        guard !DCUniMPSDKEngine.isExistsUniMP(appId) else { return }
        guard let wgtPath = Bundle.main.path(forResource: appId, ofType: "wgt") else { return }
        do {
            try DCUniMPSDKEngine.installUniMPResource(withAppid: appId, resourceFilePath: wgtPath, password: nil)
        } catch {
            print("UniMP: Failed to install bundled wgt for \(appId): \(error.localizedDescription)")
        }
    }

    // MARK: - DCUniMPSDKEngineDelegate

    func uniMP(onClose appid: String) {
        print("UniMP: \(appid) closed")
    }

    func defaultMenuItemClicked(_ appid: String, identifier: String) {
        if identifier == "close" {
            DCUniMPSDKEngine.closeUniMP()
        }
    }

    // MARK: - App Lifecycle Forwarding

    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        DCUniMPSDKEngine.applicationDidBecomeActive(application)
    }

    override func applicationWillResignActive(_ application: UIApplication) {
        super.applicationWillResignActive(application)
        DCUniMPSDKEngine.applicationWillResignActive(application)
    }

    override func applicationDidEnterBackground(_ application: UIApplication) {
        super.applicationDidEnterBackground(application)
        DCUniMPSDKEngine.applicationDidEnterBackground(application)
    }

    override func applicationWillEnterForeground(_ application: UIApplication) {
        super.applicationWillEnterForeground(application)
        DCUniMPSDKEngine.applicationWillEnterForeground(application)
    }
}
