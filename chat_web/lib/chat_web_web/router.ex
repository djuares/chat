defmodule ChatWebWeb.Router do
  use ChatWebWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatWebWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", ChatWebWeb do
  pipe_through :browser

  get "/", ChatController, :index
end


end
