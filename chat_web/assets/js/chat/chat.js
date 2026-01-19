import socket from "../socket.js"

let channel = socket.channel("room:lobby", {})

channel.join()
  .receive("ok", () => console.log("Conectado al chat"))
  .receive("error", err => console.error("Error", err))

window.send = function () {
  let input = document.getElementById("msg")
  let messages = document.getElementById("messages")

  let msg = input.value
  if (msg === "") return

  messages.innerHTML += `<p><b>yo:</b> ${msg}</p>`
  input.value = ""
}
