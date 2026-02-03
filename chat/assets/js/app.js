import { Socket } from "phoenix"
import "phoenix_html"

const socket = new Socket("/socket", { params: { token: "fake-token" } });
socket.connect();

const channel = socket.channel("room:lobby", {});
channel.join()
  .receive("ok", () => console.log("Conectado al lobby"))
  .receive("error", resp => console.error("Error al conectar", resp));

const messages = document.getElementById("messages");
const input = document.getElementById("message-input");
const button = document.getElementById("send");

// Enviar mensaje al servidor
button.onclick = () => {
  if (input.value.trim() === "") return;
  channel.push("new_msg", { body: input.value });
  input.value = "";
};

// Recibir mensaje y agregar burbuja
channel.on("group:message_reply", payload => {
  const li = document.createElement("li");
  li.className = payload.sender === "yo"
    ? "self-end bg-primary text-primary-content px-4 py-2 rounded-xl max-w-xs break-words"
    : "self-start bg-secondary text-secondary-content px-4 py-2 rounded-xl max-w-xs break-words";
  
  li.innerHTML = `<strong>${payload.sender}:</strong> ${payload.message} <div class="text-xs text-gray-500">${payload.time}</div>`;
  messages.appendChild(li);
  
  // Scroll automático al último mensaje
  messages.scrollTop = messages.scrollHeight;
});
