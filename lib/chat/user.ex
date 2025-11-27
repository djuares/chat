defmodule Chat.User do

  @enforce_keys [:contacts, :chats, :notifications]
  defstruct [:contacts, :chats, :notifications]

  def new(), do:
    %__MODULE__{contacts: MapSet.new(), chats: MapSet.new(), notifications: MapSet.new()}

  def add(%__MODULE__{} = user, :contacts, contact), do:
    update_in(user.contacts, &MapSet.put(&1, contact))

  def add(%__MODULE__{} = user, :chats, chat), do:
    update_in(user.chats, &MapSet.put(&1, chat))

  def add(%__MODULE__{} = user, :notifications, notification), do:
    update_in(user.notifications, &MapSet.put(&1, notification))
end
