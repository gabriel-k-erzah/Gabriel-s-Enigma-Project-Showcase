from flask import Flask, render_template, url_for

app = Flask(__name__)


@app.route("/")
def index():
    projects = [
        {
            "name": "Hello Enigma",
            "tagline": "A personal intro wrapped in a clean, Gen-Z-inspired design.",
            "description": (
                "A small Flask website that introduces who I am, my story, and why Enigma "
                "inspired me enough to build this showcase."
            ),
            "link": "https://github.com/GabrielErzah/Gabriel-s-Enigma-Project-Showcase/tree/main/1-hello-enigma",
        },
        {
            "name": "Offline AI CLI",
            "tagline": "An AI assistant that runs entirely offline inside the terminal.",
            "description": (
                "A fully offline command-line AI tool powered by local models via Ollama. "
                "Built to keep working even when everything else goes down (Cloudflare outage vibes)."
            ),
            "link": "https://github.com/GabrielErzah/Gabriel-s-Enigma-Project-Showcase/tree/main/2-offline-ai-cli",
        },
        {
            "name": "Quantum Exploration",
            "tagline": "My first experiments in quantum computing.",
            "description": (
                "A space where I'm learning quantum concepts step by step, starting with "
                "Shor's algorithm and exploring how quantum logic differs from classical computing."
            ),
            "link": "https://github.com/GabrielErzah/Gabriel-s-Enigma-Project-Showcase/tree/main/3-quantum-exploration",
        },
    ]

    return render_template("index.html", projects=projects)


if __name__ == "__main__":
    app.run(debug=True)