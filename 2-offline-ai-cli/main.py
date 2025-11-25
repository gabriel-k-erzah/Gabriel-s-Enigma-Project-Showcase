# This is the main CLI entry point for the offline AI.
# You’re free to swap in different local models through Ollama,
# but once you start using external APIs or cloud services,
# it stops being fully local, which goes against the whole idea of this project.

# python3 -m venv venv
# source venv/bin/activate
# pip install -r requirements.txt
# python main.py


import requests
from config import MODEL_NAME, SYSTEM_PROMPT

OLLAMA_URL = "http://localhost:11434/api/chat"


def call_ollama(user_message: str) -> str:
    """
    Send a message to the local Ollama server and return the assistant's reply.
    """
    payload = {
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_message},
        ],
        "stream": False,
    }

    try:
        response = requests.post(OLLAMA_URL, json=payload, timeout=60)
        response.raise_for_status()
        data = response.json()

        # Ollama's /api/chat typically returns:
        # { "message": { "role": "assistant", "content": "..." }, ... }
        message = data.get("message", {})
        content = message.get("content", "").strip()

        if not content:
            return "[No response from model]"

        return content

    except requests.exceptions.ConnectionError:
        return "[Error] Could not connect to Ollama. Is it running on localhost:11434?"
    except requests.exceptions.Timeout:
        return "[Error] Request to Ollama timed out."
    except Exception as e:
        return f"[Error] Unexpected problem talking to Ollama: {e}"


def main() -> None:
    print("Offline AI CLI (Ollama-based)")
    print("Type 'exit' or 'quit' to close.\n")

    while True:
        try:
            user_input = input("You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nExiting.")
            break

        if user_input.lower() in {"exit", "quit"}:
            print("Goodbye.")
            break

        if not user_input:
            continue

        reply = call_ollama(user_input)
        print(f"AI: {reply}\n")


if __name__ == "__main__":
    main()