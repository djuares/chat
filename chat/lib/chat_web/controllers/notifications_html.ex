defmodule ChatWeb.NotificationsHTML do
  use ChatWeb, :html

  import Phoenix.HTML.Form
  import Phoenix.HTML.Link

  embed_templates "notifications/*"
end
