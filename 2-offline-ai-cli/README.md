## Why Fully Offline?

This project is built to run completely offline. It uses Ollama on my machine, which exposes a local endpoint on `localhost:11434`. 
That’s not the cloud, it’s just my laptop talking to itself. All the processing stays on the device.

The idea came after the Cloudflare outage. Everything broke: websites, apps, documentation, and half the internet felt unusable. 
It was funny to watch at first, but it also made me realise how much we depend on online tools without even noticing.

With this offline setup:
- No ChatGPT.
- No powerful cloud reasoning.
- Definitely no StackOverflow with its amazing answers.
- No internet required for anything.

It’s not meant to compete with cloud systems. 
It’s more of a simple, local tool, almost like a smarter calculator, that I can use directly in the terminal, even when the internet is down.

Looking ahead, I want to move this onto a Raspberry Pi and see how far it can go. I’m planning to experiment with quantisation to shrink the model size, 
and trying to make it run on as little RAM as possible will probably be the most fun challenge in the whole project.