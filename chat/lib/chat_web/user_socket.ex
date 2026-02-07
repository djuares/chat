defmodule ChatWeb.UserSocket do
  use Phoenix.Socket

  channel "room:*", ChatWeb.RoomChannel

  @impl true
 def connect(_params, socket, _info) do
  {:ok, socket}
end


  def id(_socket), do: nil
end
