package com.rkjoeson.contact

@FunctionalInterface
interface ResponseCallback {
    fun send(data: Any?)
}