# Xenoglossy

Instantly change the tone of your text and correct grammar with one single keystroke in any app on macOS.

## Features

- Transform text with a single keyboard shortcut (⌃ + X)
- Choose between OpenAI and Gemini models
- Multiple tone options (Professional, Casual, Academic, etc.)
- Works in any app on macOS
- Menu bar app for easy access

## API Key Configuration

The app uses API keys for both OpenAI and Gemini. To set up your development environment:

1. Copy `Config.template.swift` to `Config.swift`
2. Replace the placeholder values in `Config.swift` with your API keys:
   - `openAIKey`: Your OpenAI API key
   - `geminiKey`: Your Gemini API key

For Xcode Cloud builds, the API keys are provided through environment variables:
- `OPENAI_API_KEY`
- `GEMINI_API_KEY`
