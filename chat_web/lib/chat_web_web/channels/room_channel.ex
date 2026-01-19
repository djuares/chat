defmodule ChatWebWeb.RoomChannel do
  use ChatWebWeb, :channel

  # Cuando un usuario se une al canal
  def join("room:lobby", _params, socket) do
    {:ok, socket}
  end

  # Cuando un cliente envía un mensaje
  def handle_in("new_msg", %{"body" => body}, socket) do
    IO.inspect(body, label: "Mensaje recibido")  # Se imprime en la consola del servidor
    broadcast!(socket, "new_msg", %{body: body}) # Envía a todos los clientes
    {:noreply, socket}
  end
end
