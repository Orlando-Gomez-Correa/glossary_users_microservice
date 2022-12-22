defmodule GreenhouseWeb.Auth.Guardian.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :greenhouse,
    error_handler: GreenhouseWeb.Auth.Guardian.ErrorHandler,
    module: GreenhouseWeb.Auth.Guardian.Guardian

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
  plug :assign_current_user

  defp assign_current_user(conn, _) do
    conn
    |> assign(:current_user, Guardian.Plug.current_resource(conn))
  end
end
