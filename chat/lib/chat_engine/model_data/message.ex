defmodule ChatEngine.ModelData.Message do
  @enforce_keys [:user, :content]
  defstruct [:user, :content]
end
