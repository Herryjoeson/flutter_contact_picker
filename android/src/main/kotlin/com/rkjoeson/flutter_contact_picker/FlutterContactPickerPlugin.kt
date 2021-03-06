package com.rkjoeson.flutter_contact_picker

import android.app.Activity
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

/**
 * FlutterContactPickerPlugin
 */
class FlutterContactPickerPlugin : FlutterPlugin, ActivityAware {

    private var methodChannel: MethodChannel? = null
    private var mainActivity: Activity? = null
    private var contactImpl: FlutterContactPickerImpl? = null
    private val channel = "plugins.flutter.io/flutter_contact_picker"

    /**
     * v2.0版本插件引擎初始化的时候调用
     */
    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, channel)
        contactImpl = FlutterContactPickerImpl()
        methodChannel?.setMethodCallHandler(contactImpl)
    }

    /**
     * v2.0版本插件引擎释放的时候调用
     */
    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.setMethodCallHandler(null)
        methodChannel = null
        contactImpl = null
    }

    /**
     * 插件在activity生命周期跑时挂载
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mainActivity = binding.activity
        contactImpl?.setActivity(mainActivity)
        binding.addActivityResultListener(contactImpl as PluginRegistry.ActivityResultListener)
    }

    /**
     * activity结束时释放
     */
    override fun onDetachedFromActivity() {
        contactImpl?.destroy()
        mainActivity = null
        contactImpl = null
    }

  /**
     * 配置更改期间被销毁
     */
    override fun onDetachedFromActivityForConfigChanges() {

    }

    /**
     * 重新构建配置
     */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    }
}
