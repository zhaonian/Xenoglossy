# Xenoglossy

## API Key Configuration

The app uses API keys for both OpenAI and Gemini. To set up your development environment:

1. Copy `Config.template.swift` to `Config.swift`
2. Replace the placeholder values in `Config.swift` with your API keys:
   - `openAIKey`: Your OpenAI API key
   - `geminiKey`: Your Gemini API key

For Xcode Cloud builds, the API keys are provided through environment variables:
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`
