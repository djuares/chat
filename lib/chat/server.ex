defmodule Chat.Server do
  use GenServer

  def start_link(name) when is_binary(name), do:
    GenServer.start_link(__MODULE__, name, [])

  def init(name) do
    user = %{name: name}
    {:ok, %{user: user }}
end

end
