defmodule ChatWeb.StatusChannel do
  use ChatWeb, :channel

  def join("status:lobby", _payload, socket) do
    send(self(), :after_join)
    {:ok, socket}
  end

  def terminate(_reason, socket) do
    socket.assigns.current_user.username
    |> Chat.User.update_last_online()
  end

  def handle_info(:after_join, socket) do
    user = socket.assigns.current_user

    {:ok, _} = ChatWeb.Presence.track(socket, user.username, %{
      online_at: DateTime.utc_now()
    })

    {:noreply, socket}
  end
end
