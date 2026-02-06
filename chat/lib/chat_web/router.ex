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
    plug :put_user_token
    plug :set_last_online
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/", ChatWeb do
  pipe_through :browser

  get "/", PageController, :home

    #HOME
    get "/home", HomeController, :index

    #NOTIFICATIONS
    resources "/home/notifications", NotificationsController, only: [:index, :show]

    #GROUPS
    resources "/home/groups", GroupController do
      post "/members", GroupController, :add_member
      delete "/members/:username", GroupController, :remove_member
      post "/messages", GroupMessageController, :create
    end

    # DIRECT MESSAGES
    resources "/home/directs", DirectController do
      resources "/messages", DirectMessageController, only: [:create]
    end

    # CONTACTS
    resources "/home/contacts", ContactsController, only: [:index]
    post "/home/contacts", ContactsController, :create
    post "/home/contacts/:contact_username/delete", ContactsController, :delete


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

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.username)
      assign(conn, :user_token, token)
    else
      conn
    end
  end

  def set_last_online(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && is_nil(get_session(conn, :last_online)) do
      last_online = Chat.User.get_last_online(user.username)
      put_session(conn, :last_online, last_online)
    else
      conn
    end
  end
end
