defmodule GreenhouseWeb.Router do
  use GreenhouseWeb, :router

  pipeline :api do
    plug CORSPlug,
      send_preflight_response?: false,
      origin: [
        "http://localhost:3001"
      ]

    plug :accepts, ["json"]
  end

  # pipeline :auth do
  #   plug GreenhouseWeb.Auth.Guardian.Pipeline
  # end

  scope "/api", GreenhouseWeb do
    pipe_through :api

    delete "/users/:id", UserController, :delete
    get "/users", UserController, :index
    get "/users/:id", UserController, :show_user
    put "/users/:id/update", UserController, :update
    post "/users", UserController, :create
    post "/users/confirmation", UserController, :create_password
    post "/users/update_avatar/:id", UserController, :upload_avatar
    get "/search", UserController, :search_user
    put "/users/:id/update_user", UserController, :updateUserAuth
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Users GreenHouse API",
        description: "API Documentation for GreenHouse API v1",
        termsOfService: "Open for public",
        contact: %{
          name: "Orlando Gomez",
          email: "orlando@cordage.io"
        }
      }
    }
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :greenhouse,
      swagger_file: "swagger.json"
  end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  # if Mix.env() in [:dev, :test] do
  #   import Phoenix.LiveDashboard.Router

  #   scope "/" do
  #     pipe_through [:fetch_session, :protect_from_forgery]

  #     live_dashboard "/dashboard", metrics: GreenhouseWeb.Telemetry
  #   end
  # end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      forward "/mailbox", Bamboo.SentEmailViewerPlug
    end
  end
end
