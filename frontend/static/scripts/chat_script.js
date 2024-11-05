// static/js/script.js


if(document.getElementById("chatForm")) {
    const url = window.location;
    const path = url.pathname;
    const thread_id = path.split("chat/")[1];
    document.getElementById("chatForm").addEventListener("submit", async function(event) {
            event.preventDefault();
            const userInput = document.getElementById("userInput");
            const message = userInput.value

            if (userInput.value.trim()) {
                addUserMessage(message);
                // Clear input field
                userInput.value = "";

                const bot_message = await getMessage(message, thread_id);
                addBotMessage(bot_message);
            }
        });
}

if (document.getElementById("initChat")) {
    document.getElementById("initChat").addEventListener("submit", async function(event) {
            event.preventDefault();
            const userInput = document.getElementById("userInput");
            const message = userInput.value

            if (userInput.value.trim()) {
                addUserMessage(message)
                // Clear input field
                userInput.value = "";

                const bot_message = await initChat(message)
                addBotMessage(bot_message)
            }
        });
}


async function initChat(text) {
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

async function getMessage(text, thread_id) {
    if (!text.trim()) return;

    try {
            const response = await fetch("/chat/" + thread_id, {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ message: text, thread_id: thread_id })
        });

        if (response.ok) {
            const data = await response.json();
            return data.response;
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
        <div class="bg-gray-700 p-3 rounded-lg inline-block text-white">${text}</div>
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
        <div class="bg-gray-700 p-3 rounded-lg inline-block text-white">${text}</div>
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
