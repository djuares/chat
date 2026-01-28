# lib/chat_web/plugs/current_user.ex
defmodule ChatWeb.Plugs.CurrentUser do
  import Plug.Conn
  alias Chat.Repo
  alias Chat.User

  def init(default), do: default

  def call(conn, _opts) do
    user =
      conn
      |> get_session(:current_user)  # obtenemos el username
      |> case do
        nil -> nil
        username -> Repo.get_by(User, username: username)  # buscamos usuario por username
      end

    assign(conn, :current_user, user)
  end
end
