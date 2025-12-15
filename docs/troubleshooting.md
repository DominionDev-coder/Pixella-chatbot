---
layout: default
title: Troubleshooting | Pixella Chatbot Docs
---

# 🛠️ Troubleshooting Guide
This guide provides solutions to common issues you may encounter while installing, setting up, and using Pixella. If you face any problems, refer to the sections below for troubleshooting steps.

## ❓ Common Issues

### 1. Installation Failures
- **Problem**: The installation script fails to complete.
- **Solution**:
  - Ensure you have Python 3.11 or higher installed. Check your version with `python --version` or `python3 --version`.
  - Verify that Git is installed and accessible in your terminal.
  - Check your internet connection, as the script needs to download dependencies.
  - Review the terminal output for specific error messages and address them accordingly.
### 2. Virtual Environment Issues
- **Problem**: The virtual environment (`.venv`) is not created or activated.
- **Solution**:
  - Ensure you have the `venv` module available in your Python installation.
  - Manually create a virtual environment using `python -m venv .venv`.
  - Activate the virtual environment using the appropriate command for your OS and shell.
### 3. Dependency Installation Errors
- **Problem**: Errors occur while installing dependencies from `requirements.txt`.
- **Solution**:
  - Make sure your virtual environment is activated.
  - Upgrade `pip` to the latest version using `pip install --upgrade pip`.
  - Check for specific error messages during installation and search for solutions online or in the Pixella community.
### 4. API Key Issues
- **Problem**: Pixella cannot connect to the Google Generative AI API.
- **Solution**:
  - Verify that your `GOOGLE_API_KEY` is correctly set in the `.env` file or via the CLI.
  - Ensure that your API key has the necessary permissions and is not restricted.
  - Check for any network issues that may prevent Pixella from reaching the Google API.
### 5. Configuration Problems
- **Problem**: Pixella is not using the expected configuration settings.
- **Solution**:
  - Review your `.env` file to ensure all settings are correct.
  - Use `pixella config --show` to display the current configuration and verify settings.
  - If changes were made to the `.env` file, restart Pixella to apply them.
### 6. Runtime Errors
- **Problem**: Pixella crashes or behaves unexpectedly during use.
- **Solution**:
  - Check the terminal output for error messages and stack traces.
  - Ensure that all dependencies are up to date.
  - Report bugs to the Pixella GitHub repository with detailed information about the issue.
### 7. Memory issues
- **Problem**: Pixella does not remember previous conversations or does not retain imported docs content.
- **Solution**:
  - Ensure that the `MEMORY_PATH` in your `.env` file is correctly set and that Pixella has write permissions to that directory.
  - You may need to specify what you want
  - create a new session and start a new conversation
  - Report persistent memory issues to the Pixella GitHub repository for further assistance.
### 8. RAG (Retrieval-Augmented Generation) Issues
- **Problem**: RAG features are not functioning as expected and you see "imported 0 chunks from <document_name>" when importing documents.
- **Solution**:
  - We are still working on RAG features, and they may not be fully functional yet.
### 9. Web UI Issues
- **Problem**: The web UI does not start or is unresponsive.
- **Solution**:
  - Ensure that all dependencies are installed and up to date.
  - Check for any error messages in the terminal where you started the web UI.
  - Try running the web UI in the foreground first to identify any issues before using the background mode.
### 10. Commands are breaking into chats in CLI interactive mode
- **Problem**: When using the CLI interactive mode, especially `/session` commands are being treated as chat messages while still doing their intended function.
- **Solution**:
  - This is a known issue with the CLI interactive mode. Don't worry, the commands still work as intended and Pixella may say some funny things as responses. We are working on improving this behavior in future releases.
### 11. Unsupported Models
- **Problem**: Certain AI models are not working or causing errors.
- **Solution**:
  - Not all models are supported due to the current version of the `langchain` Google GenAI integration. Refer to the [Setup and Configuration](setup.md) guide for a list of supported models.
### 12. Python Version Compatibility
- **Problem**: Pixella does not run or throws errors related to Python version.
- **Solution**:
  - Ensure you are using Python 3.11, as it is the recommended version for Pixella. Other versions may have compatibility issues.
### 13. sessions and memory inconsistencies
- **Problem**: Sessions and memory management may have occasional inconsistencies.
- **Solution**:
  - Users are advised to monitor their sessions and report any anomalies to help improve Pixella.
### 14. Background UI logging inaccuracies
- **Problem**: Background UI logging may not capture all events accurately.
- **Solution**:
  - Improvements are planned for subsequent updates. Meanwhile, consider running the UI in the foreground for more reliable logging.
### 15. Configuration persistence issues
- **Problem**: Some configuration options may not persist across Interfaces.
- **Solution**:
  - Users should verify settings after restarting Pixella chatbot and report any issues.
  - User should configure it in that interface e.g., in the CLI interactive mode, use `/name` or `/persona` commands to set those options.
### 16. `/import` command limitations
- **Problem**: The `/import` command may have limitations with certain file names.
- **Solution**:
  - rename the file with no spaces or special characters and try again.
  - use this types of names: `document.txt`, `my_doc.pdf`, `doc-notes.md`
  - Users should refer to the documentation for supported formats and ensure file names do not contain special characters that may cause issues.
### 17. CLI interactive mode input handling issues
- **Problem**: The CLI interactive mode may have occasional input handling issues.
- **Solution**:
  - Users are encouraged to report any problems encountered to help improve Pixella.
### 18. Files import types.
- **Problem**: The file import may have limitations with certain file types.
- **Solution**:
  - Currently supported file types are: `.txt`, `.md`, `.pdf`(may not import), `.docx`(may not import)
  - Users should refer to the documentation for supported formats and report any issues with file imports.

## 📞 Getting Further Help
If you have tried the above solutions and are still experiencing issues, consider the following options:
- **GitHub Issues**: Report your issue on the [Pixella GitHub Issues page](https://github.com/ObaTechHub-inc/Pixella-chatbot/issues) with detailed information about the problem.