import { Socket } from "phoenix"

// Elementos del DOM
let messages = document.getElementById("messages")
let input = document.getElementById("message-input")
let button = document.getElementById("send-button")

// Crear socket y conectarse
let socket = new Socket("/socket", {})
socket.connect()

// Crear canal
let channel = socket.channel("room:lobby", {})

// Escuchar mensajes del canal
channel.on("new_msg", payload => {
  messages.innerHTML += `<p>${payload.body}</p>`
  messages.scrollTop = messages.scrollHeight // auto-scroll
})

// Unirse al canal
channel.join()
  .receive("ok", () => console.log("Conectado al chat"))
  .receive("error", () => console.log("No se pudo conectar"))

// Enviar mensaje al presionar botón
button.addEventListener("click", () => {
  if(input.value.trim() === "") return
  console.log("Enviando mensaje:", input.value)
  channel.push("new_msg", { body: input.value })
  input.value = ""
})

// También enviar mensaje al presionar Enter
input.addEventListener("keydown", e => {
  if(e.key === "Enter" && input.value.trim() !== "") {
    channel.push("new_msg", { body: input.value })
    input.value = ""
  }
})
