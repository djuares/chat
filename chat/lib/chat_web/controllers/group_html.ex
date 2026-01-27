defmodule ChatWeb.GroupHTML do
  use ChatWeb, :html

  import Phoenix.HTML.Form
  import Phoenix.HTML.Link

  embed_templates "group/*"
end
