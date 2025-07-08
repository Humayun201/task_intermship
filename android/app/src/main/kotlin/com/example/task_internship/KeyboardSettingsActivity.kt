package com.example.task_internship

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.provider.Settings
import android.view.inputmethod.InputMethodManager
import android.widget.Toast

class KeyboardSettingsActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Check if keyboard is enabled
        if (!isKeyboardEnabled()) {
            // Open input method settings
            val intent = Intent(Settings.ACTION_INPUT_METHOD_SETTINGS)
            startActivity(intent)
            Toast.makeText(this, "Please enable CleverType AI Keyboard", Toast.LENGTH_LONG).show()
        } else if (!isKeyboardSelected()) {
            // Open input method picker
            val inputMethodManager = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
            inputMethodManager.showInputMethodPicker()
            Toast.makeText(this, "Please select CleverType AI Keyboard", Toast.LENGTH_LONG).show()
        } else {
            Toast.makeText(this, "CleverType AI Keyboard is ready!", Toast.LENGTH_SHORT).show()
        }

        finish()
    }

    private fun isKeyboardEnabled(): Boolean {
        val inputMethodManager = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        val enabledMethods = inputMethodManager.enabledInputMethodList

        return enabledMethods.any {
            it.packageName == packageName
        }
    }

    private fun isKeyboardSelected(): Boolean {
        val inputMethodManager = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        val currentMethod = Settings.Secure.getString(contentResolver, Settings.Secure.DEFAULT_INPUT_METHOD)

        return currentMethod?.contains(packageName) == true
    }
}
