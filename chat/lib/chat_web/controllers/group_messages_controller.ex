defmodule ChatWeb.GroupMessageController do
  use ChatWeb, :controller

  alias Chat.GroupMessages
  alias Chat.Repo

  def create(conn, %{
        "group_id" => group_id,
        "message" => %{"content" => content}
      }) do
    user = conn.assigns.current_user

    %Chat.GroupMessages{}
    |> Chat.GroupMessages.changeset(%{
      group_id: group_id,
      sender: user.username,
      content: content
    })
    |> Chat.Repo.insert()

    redirect(conn, to: ~p"/groups/#{group_id}")
  end

end
