package com.example.task_internship

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.content.Context
import android.view.LayoutInflater
import android.widget.LinearLayout
import android.graphics.Color
import android.view.ViewGroup
import android.widget.Button
import android.view.Gravity
import android.widget.TextView
import android.os.Handler
import android.os.Looper
import android.graphics.drawable.GradientDrawable
import android.graphics.drawable.StateListDrawable
import android.os.Vibrator
import android.media.AudioManager
import kotlinx.coroutines.*
import org.json.JSONObject
import org.json.JSONArray
import java.net.URL
import java.net.HttpURLConnection
import java.io.OutputStreamWriter
import java.io.BufferedReader
import java.io.InputStreamReader

class CleverTypeIME : InputMethodService() {

    private lateinit var keyboardView: View
    private var isShiftPressed = false
    private var isNumberMode = false
    private val geminiService = GeminiService()

    // Keyboard layouts
    private val qwertyLayout = arrayOf(
        arrayOf("q", "w", "e", "r", "t", "y", "u", "i", "o", "p"),
        arrayOf("a", "s", "d", "f", "g", "h", "j", "k", "l"),
        arrayOf("shift", "z", "x", "c", "v", "b", "n", "m", "backspace"),
        arrayOf("123", "space", "enter")
    )

    private val numberLayout = arrayOf(
        arrayOf("1", "2", "3", "4", "5", "6", "7", "8", "9", "0"),
        arrayOf("-", "/", ":", ";", "(", ")", "$", "&", "@", "\""),
        arrayOf("#+=", ".", ",", "?", "!", "'", "backspace"),
        arrayOf("ABC", "space", "enter")
    )

    override fun onCreateInputView(): View {
        keyboardView = createKeyboardView()
        return keyboardView
    }

    private fun createKeyboardView(): View {
        val mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.BLACK)
            layoutParams = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            )
        }

        // Add keyboard header (same as Flutter version)
        mainLayout.addView(createKeyboardHeader())

        // Add divider
        mainLayout.addView(createDivider())

        // Add AI Actions Row (same as Flutter version)
        mainLayout.addView(createAIActionsRow())

        // Add divider
        mainLayout.addView(createDivider())

        // Add main keyboard
        mainLayout.addView(createMainKeyboard())

        return mainLayout
    }

    private fun createKeyboardHeader(): View {
        val headerLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(Color.BLACK)
            setPadding(dpToPx(16), dpToPx(10), dpToPx(16), dpToPx(10))
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        // Left side with icon and title
        val leftLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.WRAP_CONTENT,
                1f
            )
        }

        // AI Icon with gradient background
        val iconContainer = LinearLayout(this).apply {
            setPadding(dpToPx(6), dpToPx(6), dpToPx(6), dpToPx(6))
            background = createGradientDrawable(
                intArrayOf(Color.parseColor("#9C27B0"), Color.parseColor("#2196F3")),
                dpToPx(8).toFloat()
            )
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.WRAP_CONTENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                setMargins(0, 0, dpToPx(8), 0)
            }
        }

        val iconText = TextView(this).apply {
            text = "✨"
            setTextColor(Color.WHITE)
            textSize = 16f
        }
        iconContainer.addView(iconText)

        val titleText = TextView(this).apply {
            text = "CleverType AI Keyboard"
            setTextColor(Color.WHITE)
            textSize = 16f
            typeface = android.graphics.Typeface.DEFAULT_BOLD
        }

        leftLayout.addView(iconContainer)
        leftLayout.addView(titleText)

        // Right side with settings and close buttons
        val rightLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER_VERTICAL
        }

        val settingsButton = Button(this).apply {
            text = "⚙️"
            setTextColor(Color.parseColor("#FFFFFF70"))
            setBackgroundColor(Color.TRANSPARENT)
            textSize = 20f
            layoutParams = LinearLayout.LayoutParams(
                dpToPx(40),
                dpToPx(40)
            )
        }

        val closeButton = Button(this).apply {
            text = "⌨️"
            setTextColor(Color.WHITE)
            setBackgroundColor(Color.TRANSPARENT)
            textSize = 20f
            layoutParams = LinearLayout.LayoutParams(
                dpToPx(40),
                dpToPx(40)
            )
            setOnClickListener { requestHideSelf(0) }
        }

        rightLayout.addView(settingsButton)
        rightLayout.addView(closeButton)

        headerLayout.addView(leftLayout)
        headerLayout.addView(rightLayout)

        return headerLayout
    }

    private fun createDivider(): View {
        return View(this).apply {
            setBackgroundColor(Color.parseColor("#FF808080"))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                1
            )
        }
    }

    private fun createAIActionsRow(): View {
        val aiLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setBackgroundColor(Color.BLACK)
            setPadding(dpToPx(12), dpToPx(8), dpToPx(12), dpToPx(8))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        // Grammar Check Button
        aiLayout.addView(createAIButton("📝", 0xFF2196F3.toInt(), "grammar"))
        aiLayout.addView(createSpacer())

        // Summarize Button
        aiLayout.addView(createAIButton("📄", 0xFF4CAF50.toInt(), "summarize"))
        aiLayout.addView(createSpacer())

        // Expand Button
        aiLayout.addView(createAIButton("📈", 0xFFFF9800.toInt(), "expand"))
        aiLayout.addView(createSpacer())

        // Translate Button
        aiLayout.addView(createAIButton("🌐", 0xFFF44336.toInt(), "translate"))
        aiLayout.addView(createSpacer())

        // Gemini Button (wider)
        aiLayout.addView(createGeminiButton())

        return aiLayout
    }

    private fun createAIButton(icon: String, color: Int, action: String): Button {
        return Button(this).apply {
            text = icon
            setTextColor(Color.WHITE)
            textSize = 22f
            background = createAIButtonBackground(color)
            layoutParams = LinearLayout.LayoutParams(
                0,
                dpToPx(40),
                1f
            )
            setOnClickListener { handleAIAction(action) }
        }
    }

    private fun createGeminiButton(): Button {
        return Button(this).apply {
            text = "✨ Gemini"
            setTextColor(Color.WHITE)
            textSize = 12f
            typeface = android.graphics.Typeface.DEFAULT_BOLD
            background = createGeminiButtonBackground()
            layoutParams = LinearLayout.LayoutParams(
                0,
                dpToPx(40),
                2f
            )
            setOnClickListener { handleAIAction("gemini") }
        }
    }

    private fun createSpacer(): View {
        return View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                dpToPx(8),
                LinearLayout.LayoutParams.MATCH_PARENT
            )
        }
    }

    private fun createMainKeyboard(): View {
        val keyboardLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.BLACK)
            setPadding(dpToPx(8), dpToPx(8), dpToPx(8), dpToPx(8))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }

        val currentLayout = if (isNumberMode) numberLayout else qwertyLayout

        currentLayout.forEach { row ->
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    dpToPx(50)
                ).apply {
                    setMargins(0, dpToPx(2), 0, dpToPx(2))
                }
            }

            row.forEach { key ->
                val button = createKeyButton(key)
                rowLayout.addView(button)
            }

            keyboardLayout.addView(rowLayout)
        }

        return keyboardLayout
    }

    private fun createKeyButton(key: String): Button {
        val weight = when (key) {
            "space" -> 4f
            "shift", "backspace" -> 2f
            else -> 1f
        }

        val displayText = when (key) {
            "shift" -> "⬆"
            "backspace" -> "⌫"
            "space" -> "space"
            "enter" -> "↵"
            else -> if (isShiftPressed && key.length == 1) key.uppercase() else key
        }

        val backgroundColor = when (key) {
            "shift" -> if (isShiftPressed) 0xFF9C27B0.toInt() else 0xFF707070.toInt()
            "backspace", "enter" -> 0xFF9C27B0.toInt()
            "space" -> 0xFF707070.toInt()
            "123", "ABC", "#+=" -> 0xFF707070.toInt()
            else -> 0xFF808080.toInt()
        }

        return Button(this).apply {
            text = displayText
            setTextColor(Color.WHITE)
            textSize = if (key == "space") 12f else 16f
            typeface = android.graphics.Typeface.DEFAULT
            background = createKeyBackground(backgroundColor)
            layoutParams = LinearLayout.LayoutParams(
                0,
                LinearLayout.LayoutParams.MATCH_PARENT,
                weight
            ).apply {
                setMargins(dpToPx(2), dpToPx(2), dpToPx(2), dpToPx(2))
            }
            setOnClickListener { handleKeyPress(key) }
        }
    }

    private fun createKeyBackground(color: Int): GradientDrawable {
        return GradientDrawable().apply {
            setColor(color)
            cornerRadius = dpToPx(8).toFloat()
            setStroke(1, 0xFF606060.toInt())
        }
    }

    private fun createAIButtonBackground(color: Int): StateListDrawable {
        val stateListDrawable = StateListDrawable()

        // Pressed state
        val pressedDrawable = GradientDrawable().apply {
            colors = intArrayOf(
                adjustBrightness(color, 0.7f),
                adjustBrightness(color, 0.5f)
            )
            orientation = GradientDrawable.Orientation.TOP_BOTTOM
            cornerRadius = dpToPx(10).toFloat()
        }

        // Normal state
        val normalDrawable = GradientDrawable().apply {
            colors = intArrayOf(
                adjustBrightness(color, 0.9f),
                adjustBrightness(color, 0.7f)
            )
            orientation = GradientDrawable.Orientation.TOP_BOTTOM
            cornerRadius = dpToPx(10).toFloat()
        }

        stateListDrawable.addState(intArrayOf(android.R.attr.state_pressed), pressedDrawable)
        stateListDrawable.addState(intArrayOf(), normalDrawable)

        return stateListDrawable
    }

    private fun createGeminiButtonBackground(): StateListDrawable {
        val stateListDrawable = StateListDrawable()

        // Pressed state
        val pressedDrawable = GradientDrawable().apply {
            colors = intArrayOf(
                Color.parseColor("#3367D6"),
                Color.parseColor("#0F9D58"),
                Color.parseColor("#F4B400"),
                Color.parseColor("#DB4437")
            )
            orientation = GradientDrawable.Orientation.TL_BR
            cornerRadius = dpToPx(10).toFloat()
        }

        // Normal state
        val normalDrawable = GradientDrawable().apply {
            colors = intArrayOf(
                Color.parseColor("#4285F4"),
                Color.parseColor("#34A853"),
                Color.parseColor("#FBBC05"),
                Color.parseColor("#EA4335")
            )
            orientation = GradientDrawable.Orientation.TL_BR
            cornerRadius = dpToPx(10).toFloat()
        }

        stateListDrawable.addState(intArrayOf(android.R.attr.state_pressed), pressedDrawable)
        stateListDrawable.addState(intArrayOf(), normalDrawable)

        return stateListDrawable
    }

    private fun createGradientDrawable(colors: IntArray, cornerRadius: Float): GradientDrawable {
        return GradientDrawable().apply {
            this.colors = colors
            orientation = GradientDrawable.Orientation.TL_BR
            this.cornerRadius = cornerRadius
        }
    }

    private fun adjustBrightness(color: Int, factor: Float): Int {
        val red = (Color.red(color) * factor).toInt().coerceIn(0, 255)
        val green = (Color.green(color) * factor).toInt().coerceIn(0, 255)
        val blue = (Color.blue(color) * factor).toInt().coerceIn(0, 255)
        return Color.rgb(red, green, blue)
    }

    private fun handleKeyPress(key: String) {
        // Add haptic feedback
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        vibrator.vibrate(50)

        // Add sound feedback
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.playSoundEffect(AudioManager.FX_KEYPRESS_STANDARD)

        val inputConnection = currentInputConnection ?: return

        when (key) {
            "shift" -> {
                isShiftPressed = !isShiftPressed
                refreshKeyboard()
            }
            "backspace" -> {
                inputConnection.deleteSurroundingText(1, 0)
            }
            "space" -> {
                inputConnection.commitText(" ", 1)
            }
            "enter" -> {
                inputConnection.commitText("\n", 1)
            }
            "123" -> {
                isNumberMode = true
                refreshKeyboard()
            }
            "ABC" -> {
                isNumberMode = false
                refreshKeyboard()
            }
            else -> {
                val textToInsert = if (isShiftPressed && key.length == 1) {
                    key.uppercase()
                } else {
                    key
                }
                inputConnection.commitText(textToInsert, 1)
                if (isShiftPressed && key.length == 1) {
                    isShiftPressed = false
                    refreshKeyboard()
                }
            }
        }
    }

    private fun refreshKeyboard() {
        val newView = createKeyboardView()
        setInputView(newView)
        keyboardView = newView
    }

    private fun handleAIAction(action: String) {
        val inputConnection = currentInputConnection ?: return

        // Get selected text or all text
        val selectedText = inputConnection.getSelectedText(0)?.toString()
        val textToProcess = if (!selectedText.isNullOrEmpty()) {
            selectedText
        } else {
            inputConnection.getTextBeforeCursor(1000, 0)?.toString() ?: ""
        }

        if (textToProcess.isEmpty()) {
            // Add haptic feedback for error
            val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            vibrator.vibrate(longArrayOf(0, 100, 50, 100), -1)
            return
        }

        // Add haptic feedback for processing
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        vibrator.vibrate(100)

        // Process with AI in background
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val result = geminiService.performQuickAction(textToProcess, action)

                // Update UI on main thread
                Handler(Looper.getMainLooper()).post {
                    // Replace text
                    if (selectedText != null) {
                        inputConnection.deleteSurroundingText(0, selectedText.length)
                    } else {
                        inputConnection.deleteSurroundingText(textToProcess.length, 0)
                    }
                    inputConnection.commitText(result, 1)
                }
            } catch (e: Exception) {
                e.printStackTrace()
                // Error haptic feedback
                Handler(Looper.getMainLooper()).post {
                    val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                    vibrator.vibrate(longArrayOf(0, 200, 100, 200), -1)
                }
            }
        }
    }

    private fun dpToPx(dp: Int): Int {
        return (dp * resources.displayMetrics.density).toInt()
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)

        // Reset keyboard state
        isShiftPressed = false

        // Adjust keyboard based on input type
        when (info?.inputType?.and(EditorInfo.TYPE_MASK_CLASS)) {
            EditorInfo.TYPE_CLASS_NUMBER -> {
                isNumberMode = true
            }
            EditorInfo.TYPE_CLASS_PHONE -> {
                isNumberMode = true
            }
            else -> {
                isNumberMode = false
            }
        }

        refreshKeyboard()
    }

    // Gemini Service for AI functionality (keeping your existing implementation)
    inner class GeminiService {
        private val apiKey = "AIzaSyBJWYILWfX4-Ya12zvcWQF1fHW14If6MoI"

        suspend fun performQuickAction(text: String, action: String): String {
            return withContext(Dispatchers.IO) {
                try {
                    val prompt = when (action.lowercase()) {
                        "grammar" -> "Fix the grammar and spelling mistakes in this text: \"$text\""
                        "summarize" -> "Create a concise summary of this text: \"$text\""
                        "expand" -> "Expand this text with more details and context: \"$text\""
                        "translate" -> "Translate this text to English (if not English, otherwise to Spanish): \"$text\""
                        else -> "Improve and enhance this text: \"$text\""
                    }
                    makeGeminiRequest(prompt)
                } catch (e: Exception) {
                    "Error: ${e.message}"
                }
            }
        }

        private fun makeGeminiRequest(prompt: String): String {
            val url = URL("https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey")
            val connection = url.openConnection() as HttpURLConnection

            connection.requestMethod = "POST"
            connection.setRequestProperty("Content-Type", "application/json")
            connection.doOutput = true

            val requestBody = JSONObject().apply {
                put("contents", JSONArray().apply {
                    put(JSONObject().apply {
                        put("parts", JSONArray().apply {
                            put(JSONObject().apply {
                                put("text", prompt)
                            })
                        })
                    })
                })
            }

            val writer = OutputStreamWriter(connection.outputStream)
            writer.write(requestBody.toString())
            writer.flush()
            writer.close()

            val reader = BufferedReader(InputStreamReader(connection.inputStream))
            val response = reader.readText()
            reader.close()

            val jsonResponse = JSONObject(response)
            val candidates = jsonResponse.getJSONArray("candidates")
            val firstCandidate = candidates.getJSONObject(0)
            val content = firstCandidate.getJSONObject("content")
            val parts = content.getJSONArray("parts")
            val firstPart = parts.getJSONObject(0)

            return firstPart.getString("text")
        }
    }
}
