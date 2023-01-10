defmodule Greenhouse.Shared.EmailServer do
  use Bamboo.Phoenix, view: GreenhouseWeb.EmailView
  use Bamboo.Mailer, otp_app: :greenhouse
  import Bamboo.Email
  alias Greenhouse.Accounts.User

  def send_inserted_user(%User{} = user) do
    token =
      Phoenix.Token.sign(
        GreenhouseWeb.Endpoint,
        "Confirmation",
        Map.from_struct(user)
      )

    assigns = %{
      user: user,
      url: "http://localhost:5173/create_password?token=#{token}"
    }

    new_email()
    |> from({"Glossary Team", "orlando@cordage.io"})
    |> to({"#{user.name} #{user.lastname}", user.email})
    |> subject("[Activate your account]")
    |> render("create-user-email.html", assigns)
    |> deliver_now()
  end

  def user_reset_password(%User{} = user) do
    token =
      Phoenix.Token.sign(
        GreenhouseWeb.Endpoint,
        "Confirmation",
        Map.from_struct(user)
      )

    assigns = %{
      user: user,
      url: "http://localhost:5173/reset_password?token=#{token}"
    }

    new_email()
    |> from({"Glossary Team", "orlando@cordage.io"})
    |> to({"#{user.name} #{user.lastname}", user.email})
    |> subject("[Reset your password]")
    |> render("reset-user-password.html", assigns)
    |> deliver_now()
  end
end
