package com.example.task_internship

import android.inputmethodservice.InputMethodService
import android.view.View
import android.view.inputmethod.InputConnection
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import android.graphics.Color
import android.view.Gravity
import android.view.ViewGroup
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
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

        // Header
        val header = createHeader()
        mainLayout.addView(header)

        // Divider
        mainLayout.addView(createDivider())

        // AI Actions Row
        val aiActionsRow = createAIActionsRow()
        mainLayout.addView(aiActionsRow)

        // Divider
        mainLayout.addView(createDivider())

        // Main Keyboard
        val keyboard = createMainKeyboard()
        mainLayout.addView(keyboard)

        return mainLayout
    }

    private fun createDivider(): View {
        return View(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                1
            )
            setBackgroundColor(Color.parseColor("#333333"))
        }
    }

    private fun createHeader(): View {
        val headerLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(32, 16, 32, 16)
            gravity = Gravity.CENTER_VERTICAL
        }

        // AI Icon with gradient background
        val aiIconContainer = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(6, 6, 6, 6)
            background = GradientDrawable().apply {
                colors = intArrayOf(
                    Color.parseColor("#8B5CF6"),
                    Color.parseColor("#3B82F6")
                )
                cornerRadius = 8f
                orientation = GradientDrawable.Orientation.TL_BR
            }
        }

        val aiIcon = TextView(this).apply {
            text = "✨"
            setTextColor(Color.WHITE)
            textSize = 16f
        }
        aiIconContainer.addView(aiIcon)

        // Title
        val titleText = TextView(this).apply {
            text = "CleverType AI Keyboard"
            setTextColor(Color.WHITE)
            textSize = 16f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(16, 0, 0, 0)
        }

        // Spacer
        val spacer = View(this).apply {
            layoutParams = LinearLayout.LayoutParams(0, 0, 1f)
        }

        // Close button
        val closeButton = TextView(this).apply {
            text = "⌨"
            setTextColor(Color.WHITE)
            textSize = 20f
            setPadding(16, 0, 0, 0)
            setOnClickListener { requestHideSelf(0) }
        }

        headerLayout.addView(aiIconContainer)
        headerLayout.addView(titleText)
        headerLayout.addView(spacer)
        headerLayout.addView(closeButton)

        return headerLayout
    }

    private fun createAIActionsRow(): View {
        val aiLayout = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            setPadding(12, 8, 12, 8)
        }

        // Grammar Check (spellcheck icon)
        val grammarButton = createIconOnlyAIButton("✓", "grammar", Color.parseColor("#3B82F6"))
        aiLayout.addView(grammarButton)

        // Summarize (summarize icon)
        val summarizeButton = createIconOnlyAIButton("∑", "summarize", Color.parseColor("#10B981"))
        aiLayout.addView(summarizeButton)

        // Expand (expand_more icon)
        val expandButton = createIconOnlyAIButton("↔", "expand", Color.parseColor("#F59E0B"))
        aiLayout.addView(expandButton)

        // Translate (translate icon)
        val translateButton = createIconOnlyAIButton("🌐", "translate", Color.parseColor("#EF4444"))
        aiLayout.addView(translateButton)

        // Gemini AI (with text)
        val geminiButton = createGeminiButton()
        aiLayout.addView(geminiButton)

        return aiLayout
    }

    private fun createIconOnlyAIButton(icon: String, action: String, color: Int): Button {
        return Button(this).apply {
            text = icon
            gravity = Gravity.CENTER
            setTextColor(Color.WHITE)
            textSize = 20f
            background = createGradientBackground(color)
            layoutParams = LinearLayout.LayoutParams(
                0,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                1f
            ).apply {
                setMargins(4, 0, 4, 0)
                height = 120
            }
            setOnClickListener { handleAIAction(action) }
            // Add shadow effect
            setShadowLayer(4f, 0f, 2f, color)
        }
    }

    private fun createGeminiButton(): View {
        val container = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.CENTER
            background = createGradientBackground(Color.parseColor("#4285F4"))
            layoutParams = LinearLayout.LayoutParams(
                0,
                ViewGroup.LayoutParams.WRAP_CONTENT,
                2f
            ).apply {
                setMargins(4, 0, 4, 0)
                height = 120
            }
            setOnClickListener { handleAIAction("gemini") }
        }

        // Gemini icon with white background
        val geminiIcon = TextView(this).apply {
            text = "✨"
            setTextColor(Color.parseColor("#4285F4"))
            textSize = 14f
            gravity = Gravity.CENTER
            background = GradientDrawable().apply {
                shape = GradientDrawable.OVAL
                setColor(Color.WHITE)
                cornerRadius = 100f
            }
            layoutParams = LinearLayout.LayoutParams(40, 40).apply {
                setMargins(8, 0, 0, 0)
            }
        }

        // Gemini text
        val geminiText = TextView(this).apply {
            text = "Gemini"
            setTextColor(Color.WHITE)
            textSize = 14f
            setTypeface(typeface, android.graphics.Typeface.BOLD)
            setPadding(8, 0, 8, 0)
            gravity = Gravity.CENTER
        }

        container.addView(geminiIcon)
        container.addView(geminiText)

        return container
    }

    private fun createGradientBackground(baseColor: Int): GradientDrawable {
        return GradientDrawable().apply {
            colors = intArrayOf(
                baseColor,
                Color.argb(
                    200,
                    Color.red(baseColor),
                    Color.green(baseColor),
                    Color.blue(baseColor)
                )
            )
            cornerRadius = 10f
            orientation = GradientDrawable.Orientation.TOP_BOTTOM
            setStroke(1, Color.parseColor("#444444"))
        }
    }

    private fun createMainKeyboard(): View {
        val keyboardLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(8, 8, 8, 8)
        }

        val currentLayout = if (isNumberMode) numberLayout else qwertyLayout

        currentLayout.forEach { row ->
            val rowLayout = LinearLayout(this).apply {
                orientation = LinearLayout.HORIZONTAL
                layoutParams = LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT
                ).apply {
                    setMargins(0, 4, 0, 4)
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
        val button = Button(this)

        val weight = when (key) {
            "space" -> 4f
            "shift", "backspace" -> 2f
            else -> 1f
        }

        button.layoutParams = LinearLayout.LayoutParams(0, 120, weight).apply {
            setMargins(2, 2, 2, 2)
        }

        val displayText = when (key) {
            "shift" -> if (isShiftPressed) "⇧" else "⇧"
            "backspace" -> "⌫"
            "space" -> "Space"
            "enter" -> "↵"
            else -> if (isShiftPressed && key.length == 1) key.uppercase() else key
        }

        button.text = displayText
        button.setTextColor(Color.WHITE)
        button.background = createKeyBackground(key)
        button.setOnClickListener { handleKeyPress(key) }

        return button
    }

    private fun createKeyBackground(key: String): GradientDrawable {
        val (baseColor, strokeColor) = when (key) {
            "shift" -> Pair(
                if (isShiftPressed) Color.parseColor("#8B5CF6") else Color.parseColor("#4B5563"),
                Color.parseColor("#6B7280")
            )
            "backspace" -> Pair(Color.parseColor("#4B5563"), Color.parseColor("#6B7280"))
            "enter" -> Pair(Color.parseColor("#8B5CF6"), Color.parseColor("#6B7280"))
            "space" -> Pair(Color.parseColor("#4B5563"), Color.parseColor("#6B7280"))
            "123", "ABC", "#+=" -> Pair(Color.parseColor("#4B5563"), Color.parseColor("#6B7280"))
            else -> Pair(Color.parseColor("#374151"), Color.parseColor("#6B7280"))
        }

        return GradientDrawable().apply {
            cornerRadius = 8f
            setColor(baseColor)
            setStroke(1, strokeColor)
        }
    }

    private fun handleKeyPress(key: String) {
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
        val parent = keyboardView.parent as? ViewGroup
        parent?.removeView(keyboardView)
        keyboardView = createKeyboardView()
        parent?.addView(keyboardView)
        setInputView(keyboardView)
    }

    private fun handleAIAction(action: String) {
        val inputConnection = currentInputConnection ?: return

        val extractedText = inputConnection.getExtractedText(
            android.view.inputmethod.ExtractedTextRequest(), 0
        )

        val currentText = extractedText?.text?.toString() ?: ""

        if (currentText.isEmpty()) {
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val result = geminiService.performQuickAction(currentText, action)

                Handler(Looper.getMainLooper()).post {
                    inputConnection.setSelection(0, currentText.length)
                    inputConnection.commitText(result, 1)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

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