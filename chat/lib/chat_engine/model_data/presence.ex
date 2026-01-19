defmodule ChatEngine.ModelData.Presence do
  @enforce_keys [:online]
  defstruct [:online]

  def new(), do: %__MODULE__{online: MapSet.new()}
end
