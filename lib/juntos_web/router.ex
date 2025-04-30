defmodule JuntosWeb.Router do
  use JuntosWeb, :router
  import PhoenixStorybook.Router
  import JuntosWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {JuntosWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # plug :fetch_current_user
    plug :fetch_current_scope_for_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    storybook_assets()
  end

  scope "/", JuntosWeb do
    pipe_through(:browser)
    live_storybook("/storybook", backend_module: JuntosWeb.Storybook)
  end

  scope "/", JuntosWeb do
    pipe_through :browser

    live "/users/log_in", UserLoginLive, :new
    post "/users/log_in", UserSessionController, :create

    get "/users/log_in_redirect_back_to/:event_slug",
        UserSessionController,
        :log_in_redirect_back_to

    scope "/users/auth" do
      get "/register", UserExternalAuthController, :new
      post "/register", UserExternalAuthController, :create
      get "/:provider", UserExternalAuthController, :auth_new
      get "/:provider/callback", UserExternalAuthController, :callback
    end
  end

  scope "/", JuntosWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{JuntosWeb.UserAuth, :require_authenticated}] do
      live "/new", EventLive.New
      live "/events/:event_id/edit", EventLive.Edit
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", JuntosWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:juntos, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: JuntosWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/", JuntosWeb do
    pipe_through :browser

    live_session :current_user,
      on_mount: [{JuntosWeb.UserAuth, :mount_current_scope}] do
      live "/", HomeLive, :home
      live "/home", UserEventsLive, :home
      live "/*path", EventLive.Show
    end
  end
end
