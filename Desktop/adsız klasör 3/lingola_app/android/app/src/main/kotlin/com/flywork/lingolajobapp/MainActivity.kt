package com.flywork.lingolajobapp

import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterFragmentActivity
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException

// RevenueCat Paywalls için FlutterFragmentActivity zorunlu (Android).
class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        printFacebookKeyHash()
    }

    /**
     * Facebook Login 190 "bad signature" için: Bu hash'i kopyalayıp
     * Facebook Developer Console → Facebook Login → Settings → Android → Key Hashes'e ekleyin.
     */
    private fun printFacebookKeyHash() {
        try {
            val info = packageManager.getPackageInfo(packageName, android.content.pm.PackageManager.GET_SIGNATURES)
            val signatures = info.signatures ?: emptyArray()
            for (signature in signatures) {
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val keyHash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                Log.w("FB_KEY_HASH", "Facebook Key Hash (Key Hashes'e ekleyin): $keyHash")
            }
        } catch (e: Exception) {
            Log.e("FB_KEY_HASH", "Key hash alınamadı", e)
        }
    }
}
