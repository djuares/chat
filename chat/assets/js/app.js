import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

socket.connect()

let statusChannel = socket.channel("status:lobby", {})

statusChannel.join()
    .receive("ok", resp => { console.log("Joined status channel successfully", resp) })
    .receive("error", resp => { console.log("Unable to join status channel", resp) })

export default socket
