import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  // Load API key from environment variables .env file
  static final _apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";

  late final GenerativeModel _model;

  // production constructor
  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
    );
  }

  Future<String?> analyzeJournal(
      String title, String content, String mood) async {
    try {
      final prompt = '''
        You are an empathetic AI psychologist. 
        Analyze the following journal entry. 
        Mood: $mood
        Title: $title
        Entry: "$content"
        
        Provide a short, supportive, and insightful response (max 3 sentences). 
        Address the user directly.
      ''';

      final contentObj = [Content.text(prompt)];
      final response = await _model.generateContent(contentObj);

      return response.text;
    } catch (e) {
      // If AI fails (no internet, quota exceeded), return null
      // so the app still works, just without analysis.
      return null;
    }
  }
}
