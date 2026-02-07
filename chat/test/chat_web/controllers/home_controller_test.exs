defmodule ChatWeb.HomeControllerTest do
  use ChatWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/home")
    assert html_response(conn, 200) =~ "Chat Elixir"
  end
end
