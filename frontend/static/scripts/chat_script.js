// static/js/script.js

// Function to send a message to the FastAPI backend
async function sendMessage() {
    const userInput = document.getElementById("user-input");
    const message = userInput.value;

    if (!message.trim()) return;

    displayMessage("You: " + message);
    userInput.value = "";

    try {
        const response = await fetch("/chat", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({ message: message, thread_id: "123abc" })
        });

        if (response.ok) {
            const data = await response.json();
            displayMessage("Chatbot: " + data.response);
        } else {
            displayMessage("Chatbot: Error occurred.");
        }
    } catch (error) {
        displayMessage("Chatbot: Unable to connect.");
    }
}

// Function to display messages in the chat window
function displayMessage(text) {
    const chatWindow = document.getElementById("chat-window");
    const messageElement = document.createElement("div");
    messageElement.textContent = text;
    chatWindow.appendChild(messageElement);
    chatWindow.scrollTop = chatWindow.scrollHeight;
}
