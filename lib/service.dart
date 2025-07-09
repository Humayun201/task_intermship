import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey = 'AIzaSyBJWYILWfX4-Ya12zvcWQF1fHW14If6MoI';

  Future<Map<String, String>> rewriteText(String text, String tone) async {
    try {
      final rewrittenText = await _makeRequest(text, tone);
      return {
        'Rewritten ($tone)': rewrittenText,
      };
    } catch (e) {
      print('Error in rewriteText: $e');
      throw Exception('Failed to rewrite text: $e');
    }
  }

  Future<String> performQuickAction(String text, String action) async {
    try {
      return await _makeRequest(text, action);
    } catch (e) {
      print('Error in performQuickAction: $e');
      throw Exception('Failed to perform action: $e');
    }
  }

  Future<String> _makeRequest(String text, String tone) async {
    try {

      final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';

      String prompt;
      switch (tone.toLowerCase()) {
        case 'professional':
          prompt = 'Rewrite this text in a professional business tone: "$text"';
          break;
        case 'casual':
          prompt = 'Rewrite this text in a casual, friendly tone: "$text"';
          break;
        case 'polite':
          prompt = 'Rewrite this text in a polite, respectful tone: "$text"';
          break;
        case 'creative':
          prompt = 'Rewrite this text in a creative, engaging tone: "$text"';
          break;
        case 'grammar':
          prompt = 'Fix the grammar and spelling mistakes in this text: "$text"';
          break;
        case 'summarize':
          prompt = 'Create a concise summary of this text: "$text"';
          break;
        case 'translate':
          prompt = 'Translate this text to English (if not English, otherwise to Spanish): "$text"';
          break;
        case 'expand':
          prompt = 'Expand this text with more details and context: "$text"';
          break;
        default:
          prompt = 'Improve and enhance this text: "$text"';
      }

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.8,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      print('🚀 Making request to Gemini API...');
      print('📍 URL: $url');
      print('💬 Prompt: $prompt');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('📊 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty) {
          final candidate = data['candidates'][0];
          if (candidate['content'] != null &&
              candidate['content']['parts'] != null &&
              candidate['content']['parts'].isNotEmpty) {
            final result = candidate['content']['parts'][0]['text'];

            // Fixed: Safe substring that won't cause RangeError
            final preview = result != null && result.length > 50
                ? result.substring(0, 50) + '...'
                : result ?? 'No text';

            print('✅ Success! Generated text: $preview');
            return result ?? 'No response generated';
          }
        }

        print('⚠️ No valid content in response');
        return 'No valid response from API';
      } else {
        final errorBody = response.body;
        print('❌ API Error: $errorBody');
        throw Exception('API Error ${response.statusCode}: $errorBody');
      }
    } catch (e) {
      print('💥 Network error: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<bool> testApiKey() async {
    try {
      await _makeRequest('Hello', 'casual');
      return true;
    } catch (e) {
      print('API Key test failed: $e');
      return false;
    }
  }
}
