package com.example.task_internship

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import android.util.Log

class MainActivity: FlutterActivity() {
    private val CHANNEL = "keyboard_settings"
    private val TAG = "CleverTypeDebug"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "🚀 MainActivity configureFlutterEngine called!")
        Log.d(TAG, "📱 Setting up method channel: $CHANNEL")

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "📞 Method called: ${call.method}")

            when (call.method) {
                "openKeyboardSettings" -> {
                    try {
                        Log.d(TAG, "⚙️ Opening keyboard settings...")
                        val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
                        startActivity(intent)
                        Toast.makeText(this, "Find 'CleverType AI Keyboard' and enable it", Toast.LENGTH_LONG).show()
                        result.success("Settings opened successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error opening keyboard settings: ${e.message}")
                        result.error("ERROR", "Could not open settings: ${e.message}", null)
                    }
                }
                "openInputMethodPicker" -> {
                    try {
                        Log.d(TAG, "🔄 Opening input method picker...")
                        val inputMethodManager = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                        inputMethodManager.showInputMethodPicker()
                        Toast.makeText(this, "Select 'CleverType AI Keyboard'", Toast.LENGTH_LONG).show()
                        result.success("Picker opened successfully")
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error opening input method picker: ${e.message}")
                        result.error("ERROR", "Could not open picker: ${e.message}", null)
                    }
                }
                "checkKeyboardStatus" -> {
                    try {
                        Log.d(TAG, "🔍 Checking keyboard status...")
                        val enabled = isKeyboardEnabled()
                        val selected = isKeyboardSelected()

                        Log.d(TAG, "✅ Keyboard status - Enabled: $enabled, Selected: $selected")

                        result.success(mapOf(
                            "enabled" to enabled,
                            "selected" to selected
                        ))
                    } catch (e: Exception) {
                        Log.e(TAG, "❌ Error checking keyboard status: ${e.message}")
                        result.error("ERROR", "Could not check status: ${e.message}", null)
                    }
                }
                else -> {
                    Log.w(TAG, "⚠️ Method not implemented: ${call.method}")
                    result.notImplemented()
                }
            }
        }

        Log.d(TAG, "✅ Method channel setup complete!")
    }

    private fun isKeyboardEnabled(): Boolean {
        return try {
            val inputMethodManager = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            val enabledMethods = inputMethodManager.enabledInputMethodList

            Log.d(TAG, "📋 Checking enabled keyboards:")
            enabledMethods.forEach { method ->
                Log.d(TAG, "  - ${method.packageName}: ${method.serviceName}")
            }

            val isEnabled = enabledMethods.any { method ->
                method.packageName == packageName && method.serviceName.contains("CleverTypeIME")
            }

            Log.d(TAG, "📦 Our package: $packageName")
            Log.d(TAG, "🎯 CleverType enabled: $isEnabled")

            isEnabled
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error checking if keyboard is enabled: ${e.message}")
            false
        }
    }

    private fun isKeyboardSelected(): Boolean {
        return try {
            val currentMethod = Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)
            val isSelected = currentMethod?.contains(packageName) == true

            Log.d(TAG, "🔍 Current input method: $currentMethod")
            Log.d(TAG, "📦 Our package: $packageName")
            Log.d(TAG, "🎯 CleverType selected: $isSelected")

            isSelected
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error checking if keyboard is selected: ${e.message}")
            false
        }
    }
}
