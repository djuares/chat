defmodule ChatWeb.AuthHTML do
  use ChatWeb, :html

  import Phoenix.HTML.Form
  import Phoenix.HTML.Link

  embed_templates "auth/*"
end
