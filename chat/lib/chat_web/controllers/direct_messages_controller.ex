defmodule ChatWeb.DirectMessageController do
  use ChatWeb, :controller

  alias Chat.GroupMessages
  alias Chat.Repo

  def create(conn, %{
        "direct_id" => direct_id,
        "message" => %{"content" => content}
      }) do
    user = conn.assigns.current_user

    %GroupMessages{}
    |> GroupMessages.changeset(%{
      group_id: direct_id,
      sender: user.username,
      content: content
    })
    |> Repo.insert()

    redirect(conn, to: ~p"/home/directs/#{direct_id}")
  end

end
