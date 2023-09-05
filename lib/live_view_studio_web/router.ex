defmodule LiveViewStudioWeb.Router do
  use LiveViewStudioWeb, :router

  import Surface.Catalogue.Router

  import LiveViewStudioWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {LiveViewStudioWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LiveViewStudioWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :authenticated,
      on_mount: {LiveViewStudioWeb.UserAuth, :ensure_authenticated} do
      live "/topsecret", TopSecretLive
      live "/presence", PresenceLive
    end

    live "/demo", Demo
  end

  scope "/", LiveViewStudioWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/light", LightLive
    live "/sandbox", SandboxLive
    live "/sales", SalesLive
    live "/flights", FlightsLive
    live "/boats", BoatsLive
    live "/servers", ServersLive
    live "/donations", DonationsLive
    live "/volunteers", VolunteersLive
    live "/bookings", BookingsLive
    live "/shop", ShopLive
    live "/juggling", JugglingLive
    live "/desks", DesksLive
    live "/bingo", BingoLive
    live "/vehicles", VehiclesLive
    live "/athletes", AthletesLive
    live "/pizza-orders", PizzaOrdersLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", LiveViewStudioWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:live_view_studio, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LiveViewStudioWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LiveViewStudioWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LiveViewStudioWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LiveViewStudioWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{LiveViewStudioWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end

  scope "/", LiveViewStudioWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LiveViewStudioWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      surface_catalogue("/catalogue")
    end
  end
end
