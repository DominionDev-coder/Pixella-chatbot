import streamlit as st
import logging
import sys
import os
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from chatbot import chatbot, ChatbotError, ConfigurationError, APIError

# Configure logging - suppress by default, enable with PIXELLA_DEBUG environment variable
debug_mode = os.getenv("PIXELLA_DEBUG", "0") == "1"

if debug_mode:
    logging.basicConfig(level=logging.DEBUG)
    logging.getLogger("langchain").setLevel(logging.DEBUG)
    logging.getLogger("langchain_google_genai").setLevel(logging.DEBUG)
else:
    logging.disable(logging.CRITICAL)
    logging.basicConfig(level=logging.CRITICAL)
    logging.getLogger("langchain").setLevel(logging.CRITICAL)
    logging.getLogger("langchain_google_genai").setLevel(logging.CRITICAL)
    logging.getLogger("google").setLevel(logging.CRITICAL)
    logging.getLogger("urllib3").setLevel(logging.CRITICAL)
    logging.getLogger("grpc").setLevel(logging.CRITICAL)

logger = logging.getLogger(__name__)

# Page configuration
st.set_page_config(
    page_title="Pixella Chatbot",
    page_icon="🤖",
    layout="centered",
    initial_sidebar_state="expanded",
    menu_items={"Get help": "https://github.com"}
)

# Custom CSS with enhanced styling
st.markdown("""
    <style>
        /* Main title */
        .main-title {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            text-align: center;
            font-size: 3rem;
            font-weight: 900;
            margin-bottom: 0.3rem;
            letter-spacing: 2px;
        }
        
        /* Subtitle */
        .subtitle {
            text-align: center;
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 2rem;
        }
        
        /* User message */
        .user-message {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 1.2rem;
            border-radius: 1rem;
            margin: 0.8rem 0;
            border-left: 5px solid #667eea;
            color: white;
            box-shadow: 0 4px 6px rgba(102, 126, 234, 0.2);
        }
        
        .user-label {
            font-weight: bold;
            font-size: 0.9rem;
            opacity: 0.9;
            margin-bottom: 0.5rem;
        }
        
        .user-text {
            font-size: 1rem;
            line-height: 1.5;
        }
        
        /* Bot message */
        .bot-message {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
            padding: 1.2rem;
            border-radius: 1rem;
            margin: 0.8rem 0;
            border-left: 5px solid #f5576c;
            color: white;
            box-shadow: 0 4px 6px rgba(245, 87, 108, 0.2);
        }
        
        .bot-label {
            font-weight: bold;
            font-size: 0.9rem;
            opacity: 0.9;
            margin-bottom: 0.5rem;
        }
        
        .bot-text {
            font-size: 1rem;
            line-height: 1.5;
        }
        
        /* Input area */
        .input-section {
            background: linear-gradient(135deg, rgba(102, 126, 234, 0.1), rgba(245, 87, 108, 0.1));
            padding: 1.5rem;
            border-radius: 1rem;
            margin: 1rem 0;
            border: 2px solid rgba(102, 126, 234, 0.3);
        }
        
        /* Buttons */
        .stButton > button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 0.5rem;
            font-weight: bold;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .stButton > button:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 12px rgba(102, 126, 234, 0.4);
        }
        
        /* Chat history header */
        .chat-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 1rem;
            border-radius: 0.5rem;
            margin-bottom: 1rem;
            font-weight: bold;
            text-align: center;
        }
        
        /* Footer */
        .footer {
            text-align: center;
            color: #888;
            font-size: 0.85rem;
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid #eee;
        }
        
        /* Spinner text */
        .thinking-text {
            color: #667eea;
            font-weight: bold;
        }
    </style>
""", unsafe_allow_html=True)

# Initialize session state for chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

# Header
st.markdown('<div class="main-title">🤖 PIXELLA</div>', unsafe_allow_html=True)
st.markdown('<div class="subtitle">✨ Powered by Google Generative AI (Gemini 2.0)</div>', unsafe_allow_html=True)

# Check if chatbot is initialized
if chatbot is None:
    st.error("❌ Failed to initialize chatbot. Please check your .env file and API configuration.")
    st.stop()

# Sidebar with settings
with st.sidebar:
    st.markdown("### ⚙️ Settings")
    st.divider()
    
    col1, col2 = st.columns(2)
    
    with col1:
        if st.button("🗑️ Clear History", use_container_width=True):
            st.session_state.messages = []
            st.rerun()
    
    with col2:
        if st.button("🔄 Refresh", use_container_width=True):
            st.rerun()
    
    st.divider()
    
    st.markdown("""
    ### 📋 About
    This chatbot is powered by:
    - **AI**: Google Generative AI
    - **Model**: Gemini 2.0 Flash
    - **Framework**: LangChain & Streamlit
    
    ### 💡 Tips
    - Ask questions clearly
    - Use natural language
    - Check your chat history
    """)

# Display chat history with enhanced styling
if st.session_state.messages:
    st.markdown('<div class="chat-header">💬 Chat History</div>', unsafe_allow_html=True)
    
    for message in st.session_state.messages:
        if message["role"] == "user":
            st.markdown(
                f'<div class="user-message">'
                f'<div class="user-label">👤 You</div>'
                f'<div class="user-text">{message["content"]}</div>'
                f'</div>',
                unsafe_allow_html=True
            )
        else:
            st.markdown(
                f'<div class="bot-message">'
                f'<div class="bot-label">🤖 Pixella</div>'
                f'<div class="bot-text">{message["content"]}</div>'
                f'</div>',
                unsafe_allow_html=True
            )

# Input section with gradient background
st.divider()
st.markdown('<div class="input-section">', unsafe_allow_html=True)
st.markdown("### ✉️ Send a Message")

col1, col2 = st.columns([4, 1])

with col1:
    user_input = st.text_input(
        "Your message:",
        placeholder="Type your question here...",
        label_visibility="collapsed",
        key="user_input"
    )

with col2:
    send_button = st.button("📤 Send", use_container_width=True, key="send_button")

st.markdown('</div>', unsafe_allow_html=True)

# Process user input
if send_button and user_input.strip():
    # Add user message to history
    st.session_state.messages.append({"role": "user", "content": user_input})
    
    # Get bot response
    with st.spinner("🤔 Thinking..."):
        try:
            bot_response = chatbot.chat(user_input)
            st.session_state.messages.append({"role": "assistant", "content": bot_response})
            logger.info("Message processed successfully")
            st.rerun()
        except ConfigurationError as e:
            logger.error(f"Configuration error: {e}")
            st.error(f"❌ Configuration Error: {e}")
        except APIError as e:
            logger.error(f"API error: {e}")
            st.error(f"❌ API Error: {e}\n\nPlease check your internet connection and API key.")
        except ChatbotError as e:
            logger.error(f"Chatbot error: {e}")
            st.error(f"❌ Error: {e}")
        except Exception as e:
            logger.error(f"Unexpected error: {e}")
            st.error(f"❌ Unexpected Error: {e}")

# Footer
st.markdown("""
<div class="footer">
    Built with ❤️ using Streamlit, LangChain, and Google Generative AI
</div>
""", unsafe_allow_html=True)
