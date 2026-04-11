package com.explorex.camlink.pcds;

import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.dcloud.feature.sdk.DCSDKInitConfig;
import io.dcloud.feature.sdk.DCUniMPSDK;
import io.dcloud.feature.sdk.Interface.IDCUniMPPreInitCallback;
import io.dcloud.feature.sdk.Interface.IUniMP;
import io.dcloud.feature.sdk.MenuActionSheetItem;
import io.dcloud.feature.unimp.config.IUniMPReleaseCallBack;
import io.dcloud.feature.unimp.config.UniMPOpenConfiguration;
import io.dcloud.feature.unimp.config.UniMPReleaseConfiguration;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterFragmentActivity {

    private static final String TAG = "UniMP";
    private static final String CHANNEL_NAME = "UniMP_mini_apps";
    private boolean sdkInitialized = false;
    private final HashMap<String, IUniMP> uniMPCaches = new HashMap<>();

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_NAME)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "open":
                            handleOpen(call.argument("appId"), call.argument("extraData"), result);
                            break;
                        case "close":
                            handleClose(call.argument("appId"), result);
                            break;
                        case "install":
                            handleInstall(call.argument("appId"), call.argument("wgtPath"), result);
                            break;
                        case "checkExists":
                            handleCheckExists(call.argument("appId"), result);
                            break;
                        case "getVersion":
                            handleGetVersion(call.argument("appId"), result);
                            break;
                        default:
                            result.notImplemented();
                            break;
                    }
                });
    }

    private void initSDKIfNeeded() {
        if (sdkInitialized) return;
        try {
            MenuActionSheetItem closeItem = new MenuActionSheetItem("关闭", "close");
            List<MenuActionSheetItem> sheetItems = new ArrayList<>();
            sheetItems.add(closeItem);

            DCSDKInitConfig config = new DCSDKInitConfig.Builder()
                    .setCapsule(true)
                    .setMenuDefFontSize("16px")
                    .setMenuDefFontColor("#2D2D2D")
                    .setMenuDefFontWeight("normal")
                    .setMenuActionSheetItems(sheetItems)
                    .setEnableBackground(true)
                    .build();

            DCUniMPSDK.getInstance().initialize(this, config, new IDCUniMPPreInitCallback() {
                @Override
                public void onInitFinished(boolean success) {
                    Log.d(TAG, "SDK init finished: " + success);
                }
            });

            DCUniMPSDK.getInstance().setDefMenuButtonClickCallBack((appid, id) -> {
                if ("close".equals(id)) {
                    IUniMP uniMP = uniMPCaches.get(appid);
                    if (uniMP != null && uniMP.isRuning()) {
                        uniMP.closeUniMP();
                        uniMPCaches.remove(appid);
                    }
                }
            });

            DCUniMPSDK.getInstance().setCapsuleCloseButtonClickCallBack(appid -> {
                IUniMP uniMP = uniMPCaches.get(appid);
                if (uniMP != null && uniMP.isRuning()) {
                    uniMP.closeUniMP();
                    uniMPCaches.remove(appid);
                }
            });

            sdkInitialized = true;
        } catch (Exception e) {
            Log.e(TAG, "SDK init failed", e);
        }
    }

    private void handleOpen(String appId, Map<String, Object> extraData, MethodChannel.Result result) {
        if (appId == null || appId.isEmpty()) {
            result.error("INVALID_ARGS", "appId is required", null);
            return;
        }
        try {
            initSDKIfNeeded();
            UniMPOpenConfiguration openConfig = new UniMPOpenConfiguration();
            if (extraData != null) {
                for (Map.Entry<String, Object> entry : extraData.entrySet()) {
                    openConfig.extraData.put(entry.getKey(), entry.getValue());
                }
            }
            IUniMP uniMP = DCUniMPSDK.getInstance().openUniMP(this, appId, openConfig);
            uniMPCaches.put(appId, uniMP);
            result.success(true);
        } catch (Exception e) {
            Log.e(TAG, "Open mini program failed", e);
            result.error("OPEN_FAILED", e.getMessage(), null);
        }
    }

    private void handleClose(String appId, MethodChannel.Result result) {
        if (appId == null || appId.isEmpty()) {
            result.error("INVALID_ARGS", "appId is required", null);
            return;
        }
        try {
            IUniMP uniMP = uniMPCaches.get(appId);
            if (uniMP != null && uniMP.isRuning()) {
                uniMP.closeUniMP();
                uniMPCaches.remove(appId);
            }
            result.success(true);
        } catch (Exception e) {
            result.error("CLOSE_FAILED", e.getMessage(), null);
        }
    }

    private void handleInstall(String appId, String wgtPath, MethodChannel.Result result) {
        if (appId == null || wgtPath == null) {
            result.error("INVALID_ARGS", "appId and wgtPath are required", null);
            return;
        }
        try {
            initSDKIfNeeded();
            UniMPReleaseConfiguration releaseConfig = new UniMPReleaseConfiguration();
            releaseConfig.wgtPath = wgtPath;
            DCUniMPSDK.getInstance().releaseWgtToRunPath(appId, releaseConfig, (code, pArgs) -> {
                if (code == 1) {
                    result.success(true);
                } else {
                    result.error("INSTALL_FAILED", "Install failed with code: " + code, null);
                }
            });
        } catch (Exception e) {
            result.error("INSTALL_FAILED", e.getMessage(), null);
        }
    }

    private void handleCheckExists(String appId, MethodChannel.Result result) {
        if (appId == null || appId.isEmpty()) {
            result.error("INVALID_ARGS", "appId is required", null);
            return;
        }
        try {
            initSDKIfNeeded();
            boolean exists = DCUniMPSDK.getInstance().isExistsApp(appId);
            result.success(exists);
        } catch (Exception e) {
            result.error("CHECK_FAILED", e.getMessage(), null);
        }
    }

    private void handleGetVersion(String appId, MethodChannel.Result result) {
        if (appId == null || appId.isEmpty()) {
            result.error("INVALID_ARGS", "appId is required", null);
            return;
        }
        try {
            initSDKIfNeeded();
            JSONObject info = DCUniMPSDK.getInstance().getAppVersionInfo(appId);
            if (info != null) {
                Map<String, String> versionMap = new HashMap<>();
                versionMap.put("name", info.optString("name", ""));
                versionMap.put("code", info.optString("code", ""));
                result.success(versionMap);
            } else {
                result.success(null);
            }
        } catch (Exception e) {
            result.error("VERSION_FAILED", e.getMessage(), null);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        uniMPCaches.clear();
    }
}
