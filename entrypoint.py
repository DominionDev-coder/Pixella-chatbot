#!/usr/bin/env python3
"""
Pixella - Entry point for the application
Routes between CLI chatbot and Web UI
"""

import sys
import typer
import subprocess
import os
import signal
import json
from pathlib import Path
from rich.console import Console
from rich.panel import Panel


# Fix sys.argv[0] to show 'pixella' instead of 'entrypoint.py'
sys.argv[0] = "pixella"

# Version
__version__ = "1.0.0"

# Create main Typer app for entrypoint
app = typer.Typer(
    help="Pixella - Chatbot with CLI and Web UI interfaces",
    invoke_without_command=True,
    pretty_exceptions_enable=False,
    no_args_is_help=True
)
console = Console()

# PID file for tracking background UI process
PID_FILE = os.path.expanduser("~/.pixella_ui.pid")


def version_callback(value: bool):
    """Display version and exit"""
    if value:
        console.print(f"[cyan]Pixella[/cyan] v{__version__}")
        raise typer.Exit()


@app.callback(invoke_without_command=True)
def main(
    version: bool = typer.Option(
        False,
        "--version",
        "-v",
        callback=version_callback,
        help="Show version and exit"
    ),
):
    """Pixella - Chatbot with CLI and Web UI interfaces"""
    pass


@app.command()
def cli(
    message: str = typer.Argument(None, help="Message to send to the chatbot"),
    interactive: bool = typer.Option(False, "--interactive", "-i", help="Start interactive mode"),
    debug: bool = typer.Option(False, "--debug", "-d", help="Enable debug mode"),
    verbose: bool = typer.Option(False, "--verbose", "-v", help="Show verbose output"),
):
    """
    Launch the CLI chatbot interface
    """
    try:
        from cli import app as cli_app
        
        # Build proper sys.argv for Typer to parse
        sys.argv = ["pixella"]
        
        if interactive or (not message and not debug and not verbose):
            # Default to interactive if no message provided
            sys.argv.append("interactive")
            if debug:
                sys.argv.append("--debug")
        else:
            # Chat mode
            sys.argv.append("chat")
            if message:
                sys.argv.append(message)
            if debug:
                sys.argv.append("--debug")
            if verbose:
                sys.argv.append("--verbose")
        
        cli_app()
    except KeyboardInterrupt:
        console.print("\n[yellow]Chat interrupted by user[/yellow]")
        sys.exit(0)
    except SystemExit as e:
        # Re-raise SystemExit from Typer
        raise e
    except Exception as e:
        console.print(f"\n[red]Error: {str(e)}[/red]")
        sys.exit(1)


@app.command()
def ui(
    background: bool = typer.Option(False, "--background", "-bg", help="Run UI in background"),
    end: bool = typer.Option(False, "--end", "--exit", "-e", help="Stop background UI"),
    debug: bool = typer.Option(False, "--debug", "-d", help="Enable debug logging"),
):
    """
    Launch the Web UI (Streamlit) - optionally in background mode
    """
    
    # Handle stopping background UI
    if end:
        stop_background_ui()
        return
    
    app_path = os.path.join(os.path.dirname(__file__), "app.py")
    
    # Set environment variable for debug mode
    env = os.environ.copy()
    env["PIXELLA_DEBUG"] = "1" if debug else "0"
    
    try:
        if background:
            launch_background_ui(app_path, env)
        else:
            # Launch in foreground (blocking)
            subprocess.run(
                ["streamlit", "run", app_path],
                env=env
            )
            sys.exit(0)
    except KeyboardInterrupt:
        console.print("\n[yellow]Web UI stopped by user[/yellow]")
        sys.exit(0)
    except subprocess.CalledProcessError as e:
        console.print(
            Panel(
                f"[red]Failed to launch web UI: {str(e)}[/red]",
                title="Error",
                border_style="red"
            )
        )
        sys.exit(1)
    except FileNotFoundError:
        console.print(
            Panel(
                "[red]Streamlit not found. Please install it: pip install streamlit[/red]",
                title="Error",
                border_style="red"
            )
        )
        sys.exit(1)


def launch_background_ui(app_path: str, env: dict = None):
    """Launch Streamlit UI in background and save PID"""
    if env is None:
        env = os.environ.copy()
    
    try:
        # Launch in background with nohup
        process = subprocess.Popen(
            ["streamlit", "run", app_path],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            preexec_fn=os.setsid,  # Create new process group
            env=env
        )
        
        # Save PID to file
        with open(PID_FILE, "w") as f:
            json.dump({"pid": process.pid}, f)
        
        console.print(
            Panel(
                f"[green]✓ Web UI launched in background[/green]\n"
                f"[cyan]PID: {process.pid}[/cyan]\n"
                f"[cyan]URL: http://localhost:8501[/cyan]\n\n"
                f"[dim]To stop: pixella ui --end[/dim]",
                title="🚀 Streamlit Running",
                border_style="green"
            )
        )
    except Exception as e:
        console.print(
            Panel(
                f"[red]Failed to launch background UI: {str(e)}[/red]",
                title="Error",
                border_style="red"
            )
        )
        sys.exit(1)


def stop_background_ui():
    """Stop background Streamlit UI process"""
    if not os.path.exists(PID_FILE):
        console.print(
            Panel(
                "[yellow]No background UI process found[/yellow]",
                title="ℹ️ Info",
                border_style="yellow"
            )
        )
        return
    
    try:
        with open(PID_FILE, "r") as f:
            data = json.load(f)
            pid = data.get("pid")
        
        if pid:
            try:
                # Try SIGTERM first
                os.killpg(os.getpgid(pid), signal.SIGTERM)
                import time
                time.sleep(0.5)
            except ProcessLookupError:
                pass
            
            try:
                # Force kill with SIGKILL if still running
                os.killpg(os.getpgid(pid), signal.SIGKILL)
            except ProcessLookupError:
                pass
            
            os.remove(PID_FILE)
            
            console.print(
                Panel(
                    f"[green]✓ Web UI stopped[/green]\n"
                    f"[cyan]PID: {pid}[/cyan]",
                    title="🛑 Stopped",
                    border_style="green"
                )
            )
    except (FileNotFoundError, json.JSONDecodeError) as e:
        console.print(
            Panel(
                f"[red]Failed to stop UI: {str(e)}[/red]",
                title="Error",
                border_style="red"
            )
        )
        if os.path.exists(PID_FILE):
            os.remove(PID_FILE)
        sys.exit(1)


@app.command()
def test():
    """
    Run tests from main.py
    """
    app_path = os.path.join(os.path.dirname(__file__), "main.py")
    
    try:
        result = subprocess.run(
            [sys.executable, app_path],
            capture_output=False
        )
        if result.returncode != 0:
            console.print(
                Panel(
                    f"[yellow]Tests completed with exit code {result.returncode}[/yellow]",
                    title="⚠️ Test Completed",
                    border_style="yellow"
                )
            )
        else:
            console.print(
                Panel(
                    "[green]All tests passed![/green]",
                    title="✅ Test Passed",
                    border_style="green"
                )
            )
    except FileNotFoundError:
        console.print(
            Panel(
                f"[red]Test file not found: {app_path}[/red]",
                title="Error",
                border_style="red"
            )
        )
        sys.exit(1)


if __name__ == "__main__":
    app()
