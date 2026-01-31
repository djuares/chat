defmodule ChatWeb.HomeHTML do
  use ChatWeb, :html

  import Phoenix.HTML.Form
  import Phoenix.HTML.Link

  embed_templates "home/*"
end
