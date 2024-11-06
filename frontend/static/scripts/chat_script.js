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
                createAnimation();
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

// TODO: Fixed animation chat box size
const textToAnimate = [".", "..", "..."]; // The sequence of dots
let index = 0; // Keeps track of the current dot sequence
let interval;

function startAnimation(writingElement) {
    interval = setInterval(() => {
    writingElement.textContent = textToAnimate[index];
    index = (index + 1) % textToAnimate.length; // Cycle through the dots
    }, 350); // Change dot every 500ms
}

function deleteAnimation() {
    const animation = document.getElementById("writingAnimation")
    if (animation) {
        animation.parentNode.remove();
    }
    index = 0;
}

function createAnimation() {
    addBotAnimationMessage()
    const writingElement = document.getElementById("writingAnimation");
    startAnimation(writingElement)
}

function addBotAnimationMessage() {
    const chatWindow = document.getElementById("chatWindow");

    const botMessage = document.createElement("div");
    botMessage.className = "mb-4";
    botMessage.innerHTML = `
        <p class="text-gray-500 text-sm">UsosBot</p>
        <div id="writingAnimation" class="bg-gray-700 p-3 rounded-lg inline-block text-white"></div>
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
