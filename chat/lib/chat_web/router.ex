defmodule ChatWeb.Router do
  use ChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ChatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ChatWeb.Plugs.CurrentUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/", ChatWeb do
  pipe_through :browser

    #HOME
    get "/", PageController, :home
    #GROUPS
    get "/groups", GroupController, :index
    get "/groups/new", GroupController, :new
    post "/groups", GroupController, :create
    get "/groups/:id", GroupController, :show

    post "/groups/:id/members", GroupController, :add_member
    delete "/groups/:id/members/:username", GroupController, :remove_member
    #Autentication
    get "/login", AuthController, :new
    post "/login", AuthController, :create

    get "/register", AuthController, :new_user
    post "/register", AuthController, :create_user

    delete "/logout", AuthController, :delete
  end



  # Other scopes may use custom stacks.
  # scope "/api", ChatWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:chat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ChatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
