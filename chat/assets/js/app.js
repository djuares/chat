import {Socket} from "phoenix"
import "phoenix_html"
import {initRoomChat} from "./room_chat"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

let statusChannel = socket.channel("status:lobby", {})

statusChannel.join()
    .receive("ok", resp => { console.log("Joined status channel successfully", resp) })
    .receive("error", resp => { console.log("Unable to join status channel", resp) })

// Inicializar chat cuando el DOM esté listo
document.addEventListener("DOMContentLoaded", () => {
  initRoomChat()
})

export default socket
