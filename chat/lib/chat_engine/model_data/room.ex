defmodule ChatEngine.ModelData.Room do
  @enforce_keys [:name, :users, :messages]
  defstruct [:name, :users, :messages]

  def new(name) do
    %__MODULE__{
      name: name,
      users: MapSet.new(),
      messages: []
    }
  end
end
