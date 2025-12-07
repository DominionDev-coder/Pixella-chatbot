import typer
import logging
import sys
from typing import Optional
from pathlib import Path
from rich.console import Console
from rich.panel import Panel
from rich.text import Text
from rich.prompt import Prompt
from rich.table import Table
from rich import box

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent))

from chatbot import chatbot, ChatbotError, ConfigurationError, APIError

# Suppress all logging by default
logging.disable(logging.CRITICAL)

# Configure logging - start with WARNING level, will be updated if --debug is used
logging.basicConfig(
    level=logging.WARNING,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Suppress verbose logging from dependencies by default
logging.getLogger("langchain").setLevel(logging.CRITICAL)
logging.getLogger("langchain_google_genai").setLevel(logging.CRITICAL)
logging.getLogger("google").setLevel(logging.CRITICAL)
logging.getLogger("urllib3").setLevel(logging.CRITICAL)
logging.getLogger("grpc").setLevel(logging.CRITICAL)

app = typer.Typer(help="Pixella - Chatbot CLI powered by Google Generative AI")
console = Console()


def print_rainbow_welcome():
    """Print a rainbow-colored welcome message as if from Pixella"""
    colors = ["red", "yellow", "green", "cyan", "blue", "magenta"]
    message = "Hello, I'm Pixella"
    
    rainbow_text = Text()
    for i, char in enumerate(message):
        color = colors[i % len(colors)]
        rainbow_text.append(char, style=f"bold {color}")
    
    # Display as a bot message, not a header
    welcome_panel = Panel(
        rainbow_text,
        title="[bold cyan]🤖 Pixella[/bold cyan]",
        border_style="cyan",
        box=box.ROUNDED
    )
    console.print(welcome_panel)


def print_header():
    """Print a styled header."""
    header_text = Text("🤖 PIXELLA CLI", style="bold cyan", justify="center")
    subtitle = Text("Powered by Google Generative AI", style="dim white", justify="center")
    
    panel = Panel(
        header_text + "\n" + subtitle,
        style="cyan",
        border_style="cyan",
        expand=False,
        padding=(1, 2)
    )
    console.print(panel)


def handle_error(error: Exception, context: str = "") -> None:
    """
    Handle and display errors in a user-friendly way.
    
    Args:
        error: The exception to handle
        context: Additional context about where the error occurred
    """
    logger.error(f"Error in {context}: {error}")
    
    if isinstance(error, ConfigurationError):
        error_msg = f"Configuration Error:\n{error}\n\nPlease check your .env file."
        error_color = "yellow"
    elif isinstance(error, APIError):
        error_msg = f"API Error:\n{error}\n\nPlease check your internet connection and API key."
        error_color = "red"
    elif isinstance(error, ValueError):
        error_msg = f"Input Error:\n{error}"
        error_color = "yellow"
    else:
        error_msg = f"Unexpected Error:\n{error}"
        error_color = "red"
    
    error_panel = Panel(
        Text(error_msg, style=f"bold {error_color}"),
        title="[bold red]❌ Error[/bold red]",
        border_style=error_color,
        box=box.ROUNDED
    )
    console.print(error_panel)


@app.command()
def chat(
    message: str = typer.Argument(..., help="Your message to the chatbot"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Show verbose output"),
    debug: bool = typer.Option(False, "--debug", "-d", help="Enable debug logging")
) -> None:
    """
    Send a message to the chatbot and get a response.
    
    Example:
        pixella chat "Tell me about Python"
    """
    if debug:
        logging.disable(logging.NOTSET)
        logging.getLogger().setLevel(logging.DEBUG)
        logging.getLogger("langchain").setLevel(logging.DEBUG)
        logging.getLogger("langchain_google_genai").setLevel(logging.DEBUG)
    
    print_header()
    
    if not message or not message.strip():
        handle_error(ValueError("Message cannot be empty"), "chat command")
        raise typer.Exit(code=1)
    
    if verbose:
        console.print(f"[bold yellow]📤 Sending:[/bold yellow] {message}\n")
    
    if chatbot is None:
        handle_error(ConfigurationError("Chatbot not initialized"), "chat command")
        raise typer.Exit(code=1)
    
    try:
        console.print("[bold blue]⏳ Thinking...[/bold blue]")
        response = chatbot.chat(message)
        
        # Display user message
        user_panel = Panel(
            Text(message, style="white"),
            title="[bold green]👤 You[/bold green]",
            border_style="green",
            box=box.ROUNDED
        )
        console.print(user_panel)
        
        # Display bot response
        bot_panel = Panel(
            Text(response, style="cyan"),
            title="[bold cyan]🤖 Pixella[/bold cyan]",
            border_style="cyan",
            box=box.ROUNDED
        )
        console.print(bot_panel)
        
    except ChatbotError as e:
        handle_error(e, "chat command")
        raise typer.Exit(code=1)
    except Exception as e:
        handle_error(e, "chat command")
        raise typer.Exit(code=1)


@app.command()
def interactive(
    debug: bool = typer.Option(False, "--debug", "-d", help="Enable debug logging")
) -> None:
    """
    Start an interactive chat session with the chatbot.
    
    Type 'exit', 'quit', or press Ctrl+C to end the session.
    """
    if debug:
        logging.disable(logging.NOTSET)
        logging.getLogger().setLevel(logging.DEBUG)
        logging.getLogger("langchain").setLevel(logging.DEBUG)
        logging.getLogger("langchain_google_genai").setLevel(logging.DEBUG)
    
    print_header()
    
    if chatbot is None:
        handle_error(ConfigurationError("Chatbot not initialized"), "interactive mode")
        raise typer.Exit(code=1)
    
    welcome_text = Text(
        "💬 Welcome to Interactive Mode\nType 'exit' or 'quit' to end the session.",
        style="dim cyan"
    )
    welcome_panel = Panel(
        welcome_text,
        style="cyan",
        border_style="cyan",
        expand=False
    )
    console.print(welcome_panel)
    
    # Print rainbow welcome after headers
    console.print()
    print_rainbow_welcome()
    console.print()
    
    debug_mode = debug  # Track debug mode state
    message_count = 0
    
    # Show debug hint
    if not debug_mode:
        console.print("[dim]Tip: Press F12 to toggle debug mode[/dim]\n")
    
    while True:
        try:
            user_input = Prompt.ask(
                "[bold green]You[/bold green]",
                console=console
            )
            
            # F12 key detection for debug toggle (common terminal key: ESC[ or special handling)
            if user_input.lower() in ['/debug', 'f12', '!debug']:
                debug_mode = not debug_mode
                if debug_mode:
                    logging.getLogger().setLevel(logging.DEBUG)
                    logging.getLogger("langchain").setLevel(logging.DEBUG)
                    logging.getLogger("langchain_google_genai").setLevel(logging.DEBUG)
                    console.print("[yellow]🔍 Debug mode: ON[/yellow]\n")
                else:
                    logging.getLogger().setLevel(logging.WARNING)
                    logging.getLogger("langchain").setLevel(logging.WARNING)
                    logging.getLogger("langchain_google_genai").setLevel(logging.WARNING)
                    console.print("[yellow]🔍 Debug mode: OFF[/yellow]\n")
                continue
            
            if user_input.lower() in ['exit', 'quit']:
                goodbye_panel = Panel(
                    Text("👋 Thanks for chatting! Goodbye!", style="bold yellow"),
                    border_style="yellow",
                    box=box.ROUNDED
                )
                console.print(goodbye_panel)
                break
            
            if not user_input.strip():
                continue
            
            message_count += 1
            console.print("[bold blue]⏳ Thinking...[/bold blue]")
            
            try:
                response = chatbot.chat(user_input)
                
                # Display user message
                user_panel = Panel(
                    Text(user_input, style="white"),
                    title=f"[bold green]👤 You (Message #{message_count})[/bold green]",
                    border_style="green",
                    box=box.ROUNDED
                )
                console.print(user_panel)
                
                # Display bot response
                bot_panel = Panel(
                    Text(response, style="cyan"),
                    title=f"[bold cyan]🤖 Pixella[/bold cyan]",
                    border_style="cyan",
                    box=box.ROUNDED
                )
                console.print(bot_panel)
                console.print()
                
            except ChatbotError as e:
                handle_error(e, f"message #{message_count}")
                console.print()
            except Exception as e:
                handle_error(e, f"message #{message_count}")
                console.print()
            
        except KeyboardInterrupt:
            console.print("\n")
            goodbye_panel = Panel(
                Text("👋 Interrupted. Goodbye!", style="bold yellow"),
                border_style="yellow",
                box=box.ROUNDED
            )
            console.print(goodbye_panel)
            break


@app.command()
def version() -> None:
    """Show version information."""
    version_panel = Panel(
        Text("Pixella v1.0.0\nPowered by Google Generative AI", style="bold cyan"),
        title="[bold cyan]ℹ️ Version[/bold cyan]",
        border_style="cyan",
        box=box.ROUNDED
    )
    console.print(version_panel)


if __name__ == "__main__":
    try:
        app()
    except KeyboardInterrupt:
        console.print("\n[bold yellow]👋 Interrupted by user[/bold yellow]")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        console.print(f"\n[bold red]Fatal Error: {e}[/bold red]")
        sys.exit(1)
