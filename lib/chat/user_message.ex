defmodule UserMessage do
  alias __MODULE__
  defstruct [:from, :to, :content, :timestamp]
  def new(from, to, content) do
    %UserMessage{
      from: from,
      to: to,
      content: content,
      timestamp: :os.system_time(:seconds)
    }
  end
end
