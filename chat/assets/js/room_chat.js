import socket from "./app.js"

export function initRoomChat() {
  const chatContainer = document.getElementById("chat-container")
  
  if (!chatContainer) {
    console.log("No chat-container found, skipping room chat initialization")
    return
  }
  
  const groupId = chatContainer.dataset.groupId
  const username = chatContainer.dataset.username
  
  if (!groupId || !username) {
    console.error("Missing groupId or username", {groupId, username})
    return
  }
  
  // Conectar al canal del room
  const channel = socket.channel(`room:${groupId}`, {})
  
  channel.join()
    .receive("ok", resp => {
      console.log("Joined room successfully", resp)
    })
    .receive("error", resp => {
      console.error("Unable to join room", resp)
    })
  
  // Escuchar mensajes nuevos
  channel.on("new_msg", payload => {
    appendMessage(payload, username)
  })
  
  // Manejar envío de mensajes
  const form = document.getElementById("message-form")
  const input = document.getElementById("message-input")
  
  if (form && input) {
    form.addEventListener("submit", (e) => {
      e.preventDefault()
      
      const body = input.value.trim()
      if (!body) return
      
      channel.push("new_msg", { body })
        .receive("ok", () => {
          input.value = ""
        })
        .receive("error", (err) => {
          console.error("Error sending message:", err)
        })
    })
  } else {
    console.error("Message form or input not found", {form, input})
  }
}

function appendMessage(payload, currentUsername) {
  const messagesContainer = document.getElementById("messages")
  const isMine = payload.sender === currentUsername
  
  const messageDiv = document.createElement("div")
  messageDiv.className = `chat ${isMine ? "chat-end" : "chat-start"}`
  messageDiv.innerHTML = `
    <div class="chat-bubble ${isMine ? "chat-bubble-primary" : "chat-bubble-secondary"}">
      <strong>${escapeHtml(payload.sender)}:</strong> ${escapeHtml(payload.content)}
      <small class="block text-xs opacity-70 mt-1">${escapeHtml(payload.inserted_at)}</small>
    </div>
  `
  
  messagesContainer.appendChild(messageDiv)
  messagesContainer.scrollTop = messagesContainer.scrollHeight
}

function escapeHtml(text) {
  const div = document.createElement("div")
  div.textContent = text
  return div.innerHTML
}
