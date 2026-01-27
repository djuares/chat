import { Socket } from "phoenix"

const socket = new Socket("/socket", {
  params: { token: "fake-token" }
})

socket.connect()

const channel = socket.channel("room:lobby", {})

const messages = document.getElementById("messages")
const input = document.getElementById("message-input")
const button = document.getElementById("send")

channel.join()
  .receive("ok", () => console.log("Joined lobby"))
  .receive("error", resp => console.error("Unable to join", resp))

button.onclick = () => {
  channel.push("new_msg", { body: input.value })
  input.value = ""
}

channel.on("group:message_reply", payload => {
  const li = document.createElement("li")
  li.innerText = `[${payload.sender}] ${payload.message}`
  messages.appendChild(li)
})
