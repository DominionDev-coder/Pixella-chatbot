import os
import logging
from pathlib import Path
from typing import Optional
from dotenv import load_dotenv
from langchain_google_genai import GoogleGenerativeAI
from google.api_core.exceptions import InvalidArgument, GoogleAPIError

# Configure logging
logger = logging.getLogger(__name__)


class ChatbotError(Exception):
    """Base exception for chatbot errors."""
    pass


class ConfigurationError(ChatbotError):
    """Raised when configuration is missing or invalid."""
    pass


class APIError(ChatbotError):
    """Raised when API call fails."""
    pass


class Chatbot:
    """A wrapper class for the Google Generative AI chatbot."""
    
    def __init__(self, api_key: Optional[str] = None, model: Optional[str] = None):
        """
        Initialize the chatbot with GoogleGenerativeAI LLM.
        
        Args:
            api_key: Google API key (uses env var if not provided)
            model: Model name (uses env var if not provided)
            
        Raises:
            ConfigurationError: If required environment variables are missing
        """
        # Load environment variables from .env file if it exists
        env_path = Path(__file__).parent / ".env"
        if env_path.exists():
            load_dotenv(dotenv_path=env_path)
        
        # Get API key and model
        self.api_key = api_key or os.environ.get("GOOGLE_API_KEY")
        self.model = model or os.environ.get("GOOGLE_AI_MODEL")
        
        # Validate configuration
        if not self.api_key:
            raise ConfigurationError(
                "GOOGLE_API_KEY not found. Please set it in .env file or pass it as parameter."
            )
        if not self.model:
            raise ConfigurationError(
                "GOOGLE_AI_MODEL not found. Please set it in .env file or pass it as parameter."
            )
        
        # Initialize LLM
        try:
            self.llm = GoogleGenerativeAI(
                google_api_key=self.api_key,
                model=self.model
            )
            logger.info(f"Chatbot initialized with model: {self.model}")
        except Exception as e:
            logger.error(f"Failed to initialize chatbot: {e}")
            raise ConfigurationError(f"Failed to initialize chatbot: {e}")
    
    def chat(self, message: str) -> str:
        """
        Send a message to the chatbot and get a response.
        
        Args:
            message: The user's message/query
            
        Returns:
            The chatbot's response as a string
            
        Raises:
            ValueError: If message is empty or invalid
            APIError: If API call fails
        """
        if not message or not message.strip():
            raise ValueError("Message cannot be empty")
        
        try:
            logger.debug(f"Sending message: {message[:50]}...")
            result = self.llm.invoke(message)
            logger.debug("Response received successfully")
            return result
        except InvalidArgument as e:
            logger.error(f"Invalid API argument: {e}")
            raise APIError(f"Invalid API request: {e}")
        except GoogleAPIError as e:
            logger.error(f"Google API error: {e}")
            raise APIError(f"Google API error: {e}")
        except Exception as e:
            logger.error(f"Unexpected error during chat: {e}")
            raise APIError(f"Unexpected error: {e}")


# Create a global instance for easy access
try:
    chatbot = Chatbot()
except ConfigurationError as e:
    logger.error(f"Failed to create chatbot instance: {e}")
    chatbot = None
