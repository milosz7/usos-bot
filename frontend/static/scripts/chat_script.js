// static/js/script.js

function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

if(document.getElementById("chatForm")) {
    const url = window.location;
    const path = url.pathname;
    const thread_id = path.split("chat/")[1];
    document.getElementById("chatForm").addEventListener("submit", async function(event) {
            event.preventDefault();
            const userInput = document.getElementById("userInput");
            const message = userInput.value
            userInput.disabled = true;

            if (userInput.value.trim()) {
                addUserMessage(message);
                addBotAnimationMessage();
                // Clear input field
                userInput.value = "";

                if (!message.trim()) return;

                try {
                    const response = await fetch(`/chat/${thread_id}`, {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json"
                        },
                        body: JSON.stringify({ message: message, thread_id: thread_id })
                    });

                    if (!response.ok) {
                        apendBotMessage("Error occurred.");
                        userInput.disabled = false;
                        return;
                    }
                } catch (error) {
                    apendBotMessage("Unable to connect.");
                    userInput.disabled = false;
                    return;
                }

                let chunkResponse;

                do {
                    try {
                        const response = await fetch(`/chat/next/${thread_id}`, {
                            method: "GET",
                            headers: {
                                "Content-Type": "application/json"
                            }
                        });
                        if (response.ok) {
                            if (!chunkResponse) {
                                deleteAnimation();
                                addBotMessage("");
                            }
                            const data = await response.json();
                            chunkResponse = data;
                            apendBotMessage(chunkResponse.chunk);
                        } else {
                            apendBotMessage("Error occurred.");
                            userInput.disabled = false;
                            return;
                        }
                    } catch (error) {
                        apendBotMessage("Unable to connect.");
                        userInput.disabled = false;
                        return;
                    }
                    await sleep(150);
                } while (!chunkResponse.is_finished)

                userInput.disabled = false;
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

                createAnimation()

                const bot_message = await initChat(message)
                addBotMessage(bot_message)
            }
        });
}


function deleteAnimation() {
    const animation = document.getElementById("writingAnimation")
    if (animation) {
        animation.parentNode.remove();
    }
    index = 0;
}

function addBotAnimationMessage() {
    const chatWindow = document.getElementById("chatWindow");

    const botMessage = document.createElement("div");
    botMessage.className = "mb-4 w-20";
    botMessage.innerHTML = `
        <p class="text-gray-500 text-sm">UsosBot</p>
        <div id="writingAnimation" class="bg-gray-700 h-12 px-4 rounded-lg flex items-center gap-1">
         <div class="h-3 w-3 rounded-full bg-gray-500 animate-dot1"></div>
         <div class="h-3 w-3 rounded-full bg-gray-500 animate-dot2"></div>
         <div class="h-3 w-3 rounded-full bg-gray-500 animate-dot3"></div>
        </div>
    `;
    chatWindow.appendChild(botMessage);

    chatWindow.scrollTop = chatWindow.scrollHeight;
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
    deleteAnimation()
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

function apendBotMessage(text) {
    const chatWindow = document.getElementById("chatWindow");
    const lastChild = chatWindow.lastElementChild;
    const chatText = lastChild.lastElementChild;
    chatText.innerHTML = chatText.innerHTML + text;

    chatWindow.scrollTop = chatWindow.scrollHeight;
}

document.getElementById("toggleSidebarBtn").addEventListener("click", function() {
            const sidebar = document.getElementById("sidebar");
            sidebar.classList.toggle("hidden");
        });

document.getElementById("button_logout").addEventListener("click", function() {
            window.location.href = "/logout"
        });
