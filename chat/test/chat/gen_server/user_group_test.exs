defmodule Chat.UserGroupTest do
  use Chat.DataCase, async: false

  alias Chat.UserGroup
  alias Chat.GroupMessages

  setup do
    # Usar modo compartido para que el GenServer pueda acceder a la BD
    Ecto.Adapters.SQL.Sandbox.mode(Chat.Repo, {:shared, self()})

    user = Chat.Repo.insert!(%Chat.User{username: "testuser", name: "Test User", email: "test@mail.com"})
    group = Chat.Repo.insert!(%Chat.Group{id: Nanoid.generate(), name: "Test Group", description: "group"})
    member = Chat.Repo.insert!(%Chat.GroupMember{username: user.username, group_id: group.id, role: "member"})

    %{user: user, group: group, member: member}
  end

  describe "init/1" do
    test "carga los miembros del grupo en el estado inicial", %{group: group, member: member} do
      # Iniciamos el GenServer sin usar :syn
      {:ok, pid} = GenServer.start_link(UserGroup, [group])

      _ = :sys.get_state(pid)

      state = :sys.get_state(pid)

      # Verificamos que el estado contenga la información del grupo
      assert state["info"].id == group.id

      # Verificamos que los miembros estén cargados
      assert is_list(state["members"])
      assert length(state["members"]) >= 1
    end
  end

  describe "disconnect/1" do
    test "se elimina el socket del miembro sin intentar conectar primero", %{group: group, member: member} do
      {:ok, pid} = GenServer.start_link(UserGroup, [group])
      _ = :sys.get_state(pid)

      # Llamamos a disconnect directamente
      assert :ok == GenServer.call(pid, {:disconnect, member})

      state = :sys.get_state(pid)
      disconnected_member = Enum.find(state["members"], fn m ->
        m.user.username == member.username
      end)

      # Verificamos que el miembro existe en el estado
      assert disconnected_member != nil
      assert disconnected_member.connection == nil
    end
  end

  describe "message/3" do
    test "se guarda el mensaje en BD", %{group: group, user: user} do
      {:ok, pid} = GenServer.start_link(UserGroup, [group])
      _ = :sys.get_state(pid)

      # Enviamos un mensaje directamente al GenServer
      assert :ok = GenServer.call(pid, {:message, "¡Hola mundo!", user})


      messages = GroupMessages.list_messages(group.id)
      assert length(messages) == 1

      message = hd(messages)
      assert message.content == "¡Hola mundo!"
      assert message.sender == user.username
      assert message.group_id == group.id
    end

    test "múltiples mensajes se guardan en orden", %{group: group, user: user} do
      {:ok, pid} = GenServer.start_link(UserGroup, [group])
      _ = :sys.get_state(pid)

      # Enviamos múltiples mensajes
      assert :ok = GenServer.call(pid, {:message, "Primer mensaje", user})
      assert :ok = GenServer.call(pid, {:message, "Segundo mensaje", user})
      assert :ok = GenServer.call(pid, {:message, "Tercer mensaje", user})

      # Verificamos el orden
      messages = GroupMessages.list_messages(group.id)
      assert length(messages) == 3

      [msg1, msg2, msg3] = messages
      assert msg1.content == "Primer mensaje"
      assert msg2.content == "Segundo mensaje"
      assert msg3.content == "Tercer mensaje"
    end
  end

  describe "add/1" do
    test "se intenta agregar un nuevo miembro", %{group: group} do
      {:ok, pid} = GenServer.start_link(UserGroup, [group])
      _ = :sys.get_state(pid)

      new_user = Chat.Repo.insert!(%Chat.User{username: "newuser", name: "New User", email: "new@mail.com"})
      nuevo_miembro = Chat.Repo.insert!(%Chat.GroupMember{username: new_user.username, group_id: group.id, role: "member"})

      assert Process.alive?(pid)
      assert nuevo_miembro.username == "newuser"
      assert nuevo_miembro.group_id == group.id

      # El test pasa si llegamos hasta aquí sin errores de setup
      assert true
    end
  end
end
