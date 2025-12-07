# 🤖 Pixella - AI Chatbot

**A powerful, production-ready chatbot CLI and web UI powered by Google Generative AI**

[![Python 3.11+](https://img.shields.io/badge/python-3.11%2B-blue)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🌟 Features

- ✅ **Multiple Interfaces**: CLI (Typer) + Web UI (Streamlit)
- ✅ **Error Handling**: Comprehensive error handling with user-friendly messages
- ✅ **Production Ready**: Logging, type hints, modular architecture
- ✅ **pip Packaged**: Easy installation with standard requirements.txt
- ✅ **Rich Styling**: Beautiful terminal output with colors and formatting
- ✅ **Multiple AI Models**: Support for all Google Generative AI models

## 🚀 Quick Start

### Installation

```bash
# Navigate to project directory
cd Pixella

# Install dependencies with pip
pip install -r requirements.txt
# or for Python 3.11 specifically
pip3.11 install -r requirements.txt
```

### Configuration

Create a `.env` file in the Pixella directory:

```env
GOOGLE_API_KEY=your_api_key_here
GOOGLE_AI_MODEL=gemini-2.5-flash
```

Get your API key from: https://aistudio.google.com/app/apikey

### Usage

With the `pixella` command exported to your shell environment, you can run it from anywhere:

```bash
# CLI - Chat with a question
pixella cli "What is Python?"

# CLI - Start interactive conversation
pixella cli --interactive

# Web UI - Launch Streamlit interface
pixella ui

# Show help
pixella --help
```

Or from within the Pixella directory:

```bash
./bin/pixella cli "What is Python?"
./bin/pixella ui
```

Or run directly with Python:

```bash
python3.11 entrypoint.py cli "Your question"
python3.11 entrypoint.py cli --interactive
python3.11 entrypoint.py ui
```

## 📋 Project Structure

```
Pixella/
├── bin/
│   └── pixella             # Executable wrapper script
├── cli.py                  # CLI interface (Typer) with error handling
├── app.py                  # Web UI (Streamlit) with error handling
├── chatbot.py              # Core chatbot with custom exceptions
├── entrypoint.py           # Entry point handler (routes CLI/Web)
├── requirements.txt        # Python dependencies
├── .gitignore              # Git ignore rules
├── .env                    # Environment variables (not in repo)
├── SETUP.md                # Setup guide
└── README.md               # This file
```

## 📚 Usage Examples

### CLI - Single Message

```bash
pixella cli "What is machine learning?"
pixella cli "Explain quantum computing"
```

### CLI - Interactive Mode

```bash
pixella cli --interactive
```

This launches an interactive session where you can have a conversation:

```
🤖 Pixella Interactive Chat
Type 'exit' or 'quit' to end the session.

You: What is AI?
Pixella: AI (Artificial Intelligence) is...

You: Tell me more about machine learning
Pixella: Machine Learning is a subset of AI...
```

### Web UI - Streamlit

```bash
pixella ui
```

Opens at: `http://localhost:8501`

Features:

- 💬 Real-time chat interface
- 📜 Persistent chat history
- 🎨 Beautiful gradient UI with animations
- 🗑️ Clear history button
- ⚙️ Settings configuration

## 🔧 Advanced Usage

### Using the Pixella Command (Global)

```bash
# From anywhere in your shell
pixella chat "Your question"
pixella interactive
pixella version
pixella --help
```

### From Pixella Directory

```bash
# Using the bin script directly
./bin/pixella chat "Your question"
./bin/pixella interactive
./bin/pixella web
```

### Direct Python Execution

```bash
# Run entrypoint directly (requires being in Pixella directory)
python3.11 entrypoint.py chat "Your question"
python3.11 entrypoint.py interactive
python3.11 entrypoint.py web
```

### With Debug/Verbose Flags

```bash
pixella cli "Question" --debug     # Shows debug information
pixella cli --interactive --debug  # Interactive mode with debug
```

````

## 🛡️ Error Handling

Pixella includes comprehensive error handling:

- **ConfigurationError**: Missing API keys or models
- **APIError**: Network or API issues
- **ValueError**: Invalid input
- All errors display helpful, user-friendly messages

## 🎯 Available Models

Update your `.env` file:

```env
GOOGLE_AI_MODEL=gemini-3-pro              # Most intelligent
GOOGLE_AI_MODEL=gemini-2.5-flash          # Best price-performance
GOOGLE_AI_MODEL=gemini-2.5-flash-lite     # Fastest
GOOGLE_AI_MODEL=gemini-2.5-pro            # Advanced reasoning
GOOGLE_AI_MODEL=gemini-2.0-flash          # Stable workhorse
```

## 🐛 Troubleshooting

### API Key Invalid

1. Get new key: https://aistudio.google.com/app/apikey
2. Update `.env` file
3. No extra spaces around `=`

### Module Not Found

```bash
poetry install
poetry shell
```

### Port Already in Use

```bash
poetry run streamlit run app.py --server.port 8502
```

## 📦 Distribution

```bash
# Build
poetry build

# Install from wheel
pip install dist/pixella-1.0.0-py3-none-any.whl

# Publish to PyPI
poetry publish --build
```

## 🔧 Development

```bash
# Install dev dependencies
poetry install --with dev

# Format code
poetry run black .

# Lint
poetry run ruff check .

# Type check
poetry run mypy .

# Tests
poetry run pytest
```

## 📖 Documentation

See [INSTALLATION.md](INSTALLATION.md) for detailed setup, troubleshooting, and development guide.

## 📄 License

MIT License - See LICENSE file

## 🙏 Built With

- [LangChain](https://www.langchain.com/) - AI framework
- [Typer](https://typer.tiangolo.com/) - CLI framework
- [Streamlit](https://streamlit.io/) - Web UI
- [Rich](https://rich.readthedocs.io/) - Terminal styling
- [Google Generative AI](https://ai.google.dev/) - AI models
- [Poetry](https://python-poetry.org/) - Package management
````
