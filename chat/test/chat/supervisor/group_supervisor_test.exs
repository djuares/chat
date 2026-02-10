defmodule Chat.Supervisor.GroupSupervisorTest do
  use ExUnit.Case

  test "starts the GroupSupervisor" do
    {:ok, pid} = Chat.Supervisor.GroupSupervisor.start_link([])
    assert Process.alive?(pid)
  end

end
