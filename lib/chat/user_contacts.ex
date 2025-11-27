defmodule Chat.UserContacts do
  alias __MODULE__
  defstruct contacts: MapSet.new()
  def new do
    %UserContacts{}
  end
end
