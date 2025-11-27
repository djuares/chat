defmodule Chat.UserChats do
  alias __MODULE__
  defstruct chats: MapSet.new()
  def new do
    %UserChats{}
  end

end
