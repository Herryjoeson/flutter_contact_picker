package com.rkjoeson.contact

import android.app.Activity
import android.content.ContentResolver
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import androidx.annotation.RequiresApi
import io.flutter.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

open class ContactImpl : PluginRegistry.ActivityResultListener, MethodChannel.MethodCallHandler {

    private val contactPageCode: Int = 1
    private var responseCallback: ResponseCallback? = null

    private var activity: Activity? = null

    open fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    /**
     * flutter调用原生方法
     */
    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 注册回调方法
        when (call.method) {
            MethodConstants.METHOD_CALL_LIST -> {
                responseCallback = object : ResponseCallback {
                    override fun send(data: Any?) {
                        result.success(data)
                    }
                }
                getContactList()
            }
            MethodConstants.METHOD_CALL_GO_TO_CONTACT -> {
                responseCallback = object : ResponseCallback {
                    override fun send(data: Any?) {
                        result.success(data)
                    }
                }
                goToContact()
            }
            else -> {
                // 未知方法
                result.notImplemented()
            }
        }
    }

    /**
     * 对应的activity需要回调结果
     */
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        when (requestCode) {
            contactPageCode -> {
                if (data !== null) {
                    val contact = hashMapOf("contactName" to "", "phoneNumber" to "")
                    val intentData: Uri? = data.data

                    if (intentData == null) {
                        Log.i(this.javaClass.name, "跳转对应的通讯录页面为空")
                        responseCallback?.send(contact)
                        return true
                    }

                    val contentResolver: ContentResolver? = activity?.contentResolver
                    var cursor: Cursor? = null

                    if (contentResolver != null) {
                        cursor = contentResolver.query(intentData, arrayOf("display_name", "data1"), null, null, null)
                    } else {
                        Log.i(this.javaClass.name, "contentResolver为空")
                        responseCallback?.send(contact)
                        return true
                    }

                    while (cursor!!.moveToNext()) {
                        contact["contactName"] = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                        val phone: String = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))
                        Log.i(this.javaClass.name, phone.toString())
                        contact["phoneNumber"] = phone.replace("-", "")
                        contact["phoneNumber"] = phone.replace(" ", "")
                    }

                    cursor.close()
                    responseCallback?.send(contact)
                }
            }
            else -> {

            }
        }

        return true
    }

    /**
     * 跳转到联系人界面
     */
    private fun goToContact() {
        val intent = Intent()
        // 启动的界面,属于哪一种动作.pick,代表的是选择内容,选取某个数据
        intent.action = "android.intent.action.PICK"
        intent.addCategory("android.intent.category.DEFAULT")
        // 用于界定,选择的是什么类型的数据(这里需要获取电话号码数据)
        intent.type = "vnd.android.cursor.dir/phone_v2"
        activity?.startActivityForResult(intent, contactPageCode)
    }

    /**
     * 获取联系人的列表数据
     */
    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    private fun getContactList() {
        val phoneBookLabel = "phonebook_label"
        val contactProjection = arrayOf(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME, ContactsContract.CommonDataKinds.Phone.NUMBER, phoneBookLabel)
        val contacts = arrayListOf<HashMap<String, String>>()

        val cursor: Cursor? = activity?.contentResolver?.query(
                ContactsContract.CommonDataKinds.Contactables.CONTENT_URI,
                contactProjection,
                null,
                null,
                ContactsContract.CommonDataKinds.Phone.SORT_KEY_PRIMARY
        )

        if (cursor != null) {
            while (cursor.moveToNext()) {

                val map = HashMap<String, String>()
                val name = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                val firstChar = cursor.getString(cursor.getColumnIndex(phoneBookLabel))
                val phone: String = cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))

                map["contactName"] = name
                map["phoneNumber"] = phone.replace("-", "")
                map["phoneNumber"] = phone.replace(" ", "")
                map["firstLetter"] = firstChar

                contacts.add(map)
            }

            cursor.close()
            responseCallback?.send(contacts)
        }
    }

    /**
     * 销毁引用
     */
    fun destroy() {
        activity = null
    }
}