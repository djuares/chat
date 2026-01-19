defmodule ChatWebWeb.ChatController do
  use ChatWebWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
