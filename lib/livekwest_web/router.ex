defmodule LivekwestWeb.Router do
  use LivekwestWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LivekwestWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug LivekwestWeb.Utils.Plugs.AuthPlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LivekwestWeb do
    pipe_through [:browser, :authenticated]

    live "/", DashboardLive
    live "/control/:id", ControlLive
    live "/present/:code", PresentationLive
  end

  scope "/", LivekwestWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/login", SessionController, :new
    post "/login", SessionController, :create
    delete "/logout", SessionController, :delete

    live "/join", JoinLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LivekwestWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:livekwest, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LivekwestWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
