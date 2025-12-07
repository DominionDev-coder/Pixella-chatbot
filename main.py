import os
from pathlib import Path
from dotenv import load_dotenv
from chatbot import chatbot


# Load environment variables from .env file
env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)


GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")
GOOGLE_AI_MODEL = os.environ.get("GOOGLE_AI_MODEL")

# Validate environment variables are loaded
if not GOOGLE_API_KEY or not GOOGLE_AI_MODEL:
    raise ValueError(f"Missing environment variables. API Key loaded: {bool(GOOGLE_API_KEY)}, Model: {GOOGLE_AI_MODEL}")


def main():
    """Run a simple test query with the chatbot."""
    result = chatbot.chat("Hello!")
    print(result)


if __name__ == "__main__":
    main()