defmodule Chat.Supervisor.GroupSupervisorTest do
  use ExUnit.Case

  setup do
    {:ok, sup} = Chat.Supervisor.GroupSupervisor.start_link([])
    %{sup: sup}
  end

  test "supervisor starts", %{sup: sup} do
    assert Process.alive?(sup)
  end

  test "can create a child under supervisor", %{sup: _sup} do
    # creamos un group mínimo de prueba
    group = %Chat.Group{id: 1, name: "Test Group"}

    # llamamos a create/1
    {:ok, pid} = Chat.Supervisor.GroupSupervisor.create(group)

    # verificamos que el child está vivo
    assert Process.alive?(pid)
  end
end
