# Pixella - Setup Guide

## Prerequisites

- Python 3.11 or higher
- pip (usually comes with Python)
- Google API Key

## Installation

### 1. Navigate to Project Directory

```bash
cd Pixella
```

### 2. Install Dependencies

```bash
# Install all required packages
pip3.11 install -r requirements.txt

# Or if pip3.11 is not in PATH
python3.11 -m pip install -r requirements.txt
```

### 3. Configure Environment

Create a `.env` file in the Pixella directory:

```env
GOOGLE_API_KEY=your_api_key_here
GOOGLE_AI_MODEL=gemini-2.5-flash
```

**Get your API key:** https://aistudio.google.com/app/apikey

### 4. Verify Installation

```bash
# Test the CLI
./bin/pixella cli

# Or run directly with Python
python3.11 entrypoint.py cli
```

Expected output:

```
╭────────────────────────────────── ℹ️ Version ───────────────────────────────────╮
│ Pixella v1.0.0                                                                  │
│ Powered by Google Generative AI                                                │
╰───────────────────────────────────────────────────────────────────────────────╯
```

## Running Pixella

### Using the pixella Command

```bash
# Chat with a single message
./bin/pixella cli "What is Python?"

# Interactive mode (conversation)
./bin/pixella cli --interactive

# Launch web UI (Streamlit)
./bin/pixella ui

# Show help
./bin/pixella --help
```

### Using Python Directly

```bash
python3.11 entrypoint.py cli "Your question"
python3.11 entrypoint.py cli --interactive
python3.11 entrypoint.py ui
```

### Using CLI Module Directly

```bash
python3.11 cli.py chat "Your question"
python3.11 cli.py interactive
python3.11 app.py  # For web UI
```

## Troubleshooting

### Python 3.11 Not Found

```bash
# Check if python3.11 is installed
which python3.11
python3.11 --version

# If not found, install Python 3.11
# macOS: brew install python@3.11
# Ubuntu: sudo apt install python3.11
```

### Module Import Errors

```bash
# Reinstall dependencies
pip3.11 install --upgrade -r requirements.txt

# Or with explicit upgrade
pip3.11 install --force-reinstall -r requirements.txt
```

### .env File Not Loading

Check your `.env` file:

- No spaces around `=`: `GOOGLE_API_KEY=your_key`
- Not like: `GOOGLE_API_KEY = your_key`
- Not empty values: `GOOGLE_API_KEY=` (bad)

### Streamlit Port Already in Use

```bash
# Use a different port
streamlit run app.py --server.port 8502

# Or kill existing process
lsof -ti:8501 | xargs kill -9
```

## Project Structure

```
Pixella/
├── bin/
│   └── pixella         # Executable wrapper script
├── cli.py              # CLI interface (Typer)
├── app.py              # Web UI (Streamlit)
├── chatbot.py          # Core chatbot logic
├── entrypoint.py       # Entry point handler
├── requirements.txt    # Python dependencies
├── .env                # Your API key (not in repo)
├── .gitignore          # Git configuration
├── README.md           # Main documentation
└── SETUP.md            # This file
```

## Quick Commands Reference

```bash
# Installation
pip3.11 install -r requirements.txt

# Running
./bin/pixella cli "question"
./bin/pixella cli --interactive
./bin/pixella ui

# Direct Python
python3.11 entrypoint.py cli "question"
python3.11 entrypoint.py cli --interactive
python3.11 entrypoint.py ui

# Help
./bin/pixella --help
./bin/pixella cli --help
```

## Support

For issues:

1. Check `.env` file is correctly formatted
2. Verify Python 3.11 is installed: `python3.11 --version`
3. Reinstall dependencies: `pip3.11 install --upgrade -r requirements.txt`
4. Check API key is valid: https://aistudio.google.com/app/apikey

---

**Pixella v1.0.0** - Powered by Google Generative AI
