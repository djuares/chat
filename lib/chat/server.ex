defmodule Chat.Server do
  use GenServer
  alias Chat.{UserChats, UserContacts}

  def start_link(name) when is_binary(name), do:
    GenServer.start_link(__MODULE__, name, [])

  def init(name) do
    user = %{name: name, chats: UserChats.new(), contacts: UserContacts.new()}
    {:ok, %{user: user }}
end

end
