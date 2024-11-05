// static/js/script.js

document.getElementById("chatForm").addEventListener("submit", async function(event) {
            event.preventDefault();
            const userInput = document.getElementById("userInput");
            const message = userInput.value

            if (userInput.value.trim()) {
                addUserMessage(message)
                // Clear input field
                userInput.value = "";

                const bot_message = await getMessage(message)
                addBotMessage(bot_message)
            }
        });

async function getMessage(text) {
    if (!text.trim()) return;

    try {
            const response = await fetch("/chat", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ message: text })
        });

        if (response.ok) {
            const data = await response.json();
            window.location.href = `/chat/${data.response}`
        } else {
            return "Error occurred."
        }
    } catch (error) {
        return "Unable to connect."
    }
}

function addUserMessage(text) {
    const chatWindow = document.getElementById("chatWindow");

    const userMessage = document.createElement("div");
    userMessage.className = "mb-4 text-right";
    userMessage.innerHTML = `
        <p class="text-gray-500 text-sm">Ty</p>
        <div class="bg-purple_3 p-3 rounded-lg inline-block text-white">${text}</div>
    `;
    chatWindow.appendChild(userMessage);

    chatWindow.scrollTop = chatWindow.scrollHeight;
}

function addBotMessage(text) {
    const chatWindow = document.getElementById("chatWindow");

    const botMessage = document.createElement("div");
    botMessage.className = "mb-4";
    botMessage.innerHTML = `
        <p class="text-gray-500 text-sm">UsosBot</p>
        <div class="bg-purple_3 p-3 rounded-lg inline-block text-white">${text}</div>
    `;
    chatWindow.appendChild(botMessage);

    chatWindow.scrollTop = chatWindow.scrollHeight;
}

document.getElementById("toggleSidebarBtn").addEventListener("click", function() {
            const sidebar = document.getElementById("sidebar");
            sidebar.classList.toggle("hidden");
        });

document.getElementById("button_logout").addEventListener("click", function() {
            window.location.href = "/logout"
        });
