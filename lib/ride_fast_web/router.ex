defmodule RideFastWeb.Router do
  use RideFastWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug RideFastWeb.Plugs.Locale
  end

  pipeline :auth do
    plug RideFastWeb.AuthPipeline
  end

  pipeline :admin do
    plug RideFastWeb.Plugs.AdminOnly
  end

  # ============================================
  # ROTAS PÚBLICAS
  # ============================================
  scope "/api/v1", RideFastWeb do
    pipe_through :api

    # Health check
    get "/status", StatusController, :index

    # Autenticação
    post "/auth/register", AuthController, :register
    post "/auth/login", AuthController, :login
    post "/auth/logout", AuthController, :logout

    # Idiomas (público)
    get "/languages", LanguageController, :index

    # Motoristas (listagem pública)
    get "/drivers", DriverController, :index
    get "/drivers/:id", DriverController, :show

    # Ratings públicos
    get "/drivers/:driver_id/ratings", RatingController, :driver_ratings
    get "/rides/:ride_id/ratings", RatingController, :ride_ratings

    # Idiomas de um motorista (público)
    get "/drivers/:driver_id/languages", DriverLanguageController, :index
  end

  # ============================================
  # ROTAS AUTENTICADAS (qualquer usuário logado)
  # ============================================
  scope "/api/v1", RideFastWeb do
    pipe_through [:api, :auth]

    # Users (próprio usuário ou admin)
    get "/users/me", UserController, :me
    get "/users/:id", UserController, :show
    put "/users/:id", UserController, :update
    delete "/users/:id", UserController, :delete

    # Drivers (próprio driver ou admin)
    put "/drivers/:id", DriverController, :update
    delete "/drivers/:id", DriverController, :delete

    # Driver Profile
    get "/drivers/:driver_id/profile", DriverProfileController, :show
    post "/drivers/:driver_id/profile", DriverProfileController, :create
    put "/drivers/:driver_id/profile", DriverProfileController, :update

    # Driver Languages (associação)
    post "/drivers/:driver_id/languages/:language_id", DriverLanguageController, :create
    delete "/drivers/:driver_id/languages/:language_id", DriverLanguageController, :delete

    # Vehicles
    get "/drivers/:driver_id/vehicles", VehicleController, :index
    post "/drivers/:driver_id/vehicles", VehicleController, :create
    put "/vehicles/:id", VehicleController, :update
    delete "/vehicles/:id", VehicleController, :delete

    # Rides
    get "/rides", RideController, :index
    get "/rides/:id", RideController, :show
    post "/rides", RideController, :create
    post "/rides/:id/accept", RideController, :accept
    post "/rides/:id/start", RideController, :start
    post "/rides/:id/complete", RideController, :complete
    post "/rides/:id/cancel", RideController, :cancel
    get "/rides/:id/history", RideController, :history

    # Ratings (após corrida)
    post "/rides/:ride_id/ratings", RatingController, :create

    # Payments (consulta)
    get "/payments/ride/:ride_id", PaymentController, :by_ride
  end

  # ============================================
  # ROTAS ADMIN (somente admin)
  # ============================================
  scope "/api/v1/admin", RideFastWeb do
    pipe_through [:api, :auth, :admin]

    # Users admin
    get "/users", UserController, :index
    post "/users", UserController, :create

    # Drivers admin
    post "/drivers", DriverController, :create

    # Languages admin
    post "/languages", LanguageController, :create
    put "/languages/:id", LanguageController, :update
    delete "/languages/:id", LanguageController, :delete

    # Payments admin
    get "/payments", PaymentController, :index

    # Rides admin
    get "/rides/all", RideController, :all
  end

  # Dev environment mailbox preview
  if Application.compile_env(:ride_fast, :dev_routes) do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
