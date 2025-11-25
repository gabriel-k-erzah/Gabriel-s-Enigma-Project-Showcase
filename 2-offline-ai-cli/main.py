# This is the main CLI entry point for the offline AI.
# You’re free to swap in different local models through Ollama,
# but once you start using external APIs or cloud services,
# it stops being fully local, which goes against the whole idea of this project.

# python3 -m venv venv
# source venv/bin/activate
# pip install -r requirements.txt
# ollama pull llama3
# python main.py

import requests
from config import MODEL_NAME, SYSTEM_PROMPT

OLLAMA_URL = "http://localhost:11434/api/chat"

# helper to detect whether this Ollama version supports /api/chat.
def supports_chat_api() -> bool:
    try:
        r = requests.post(
            "http://localhost:11434/api/chat",
            json={"model": MODEL_NAME, "messages": []},
            timeout=2,
        )
        # If the endpoint exists, it should NOT return 404
        return r.status_code != 404
    except Exception:
        return False

# pick endpoint + mode based on what the local Ollama server supports.
if supports_chat_api():
    OLLAMA_URL = "http://localhost:11434/api/chat"
    USE_CHAT = True
else:
    OLLAMA_URL = "http://localhost:11434/api/generate"
    USE_CHAT = False


def call_ollama(user_message: str) -> str:
    """
    Send a message to the local Ollama server and return the assistant's reply.
    This works with either /api/chat or /api/generate depending on USE_CHAT.
    """

    # build the payload differently depending on which API we’re using.
    if USE_CHAT:
        payload = {
            "model": MODEL_NAME,
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": user_message},
            ],
            "stream": False,
        }
    else:
        payload = {
            "model": MODEL_NAME,
            "prompt": f"{SYSTEM_PROMPT}\nUser: {user_message}\nAI:",
            "stream": False,
        }

    try:
        response = requests.post(OLLAMA_URL, json=payload, timeout=60)
        response.raise_for_status()
        data = response.json()

        # parse the response based on the API style.
        if USE_CHAT:
            # /api/chat → { "message": { "role": "...", "content": "..." }, ... }
            message = data.get("message", {})
            content = message.get("content", "").strip()
        else:
            # /api/generate → { "response": "..." , ... }
            content = data.get("response", "").strip()

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