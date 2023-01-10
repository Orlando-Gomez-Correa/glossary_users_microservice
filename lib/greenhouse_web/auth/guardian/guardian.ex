defmodule GreenhouseWeb.Auth.Guardian.Guardian do
  use Guardian, otp_app: :greenhouse

  # alias Greenhouse.Repo
  # alias Greenhouse.Accounts.User
  # alias Greenhouse.Accounts

  # def subject_for_token(user, _claims) do
  #   sub = to_string(user["id"])
  #   # to_string(user["id"])
  #   {:ok, sub}
  # end

  # def resource_from_claims(%{"https://email" => email}) do
  #   Repo.get_by(User, email: email)
  #   |> case do
  #     nil -> {:error, :not_found}
  #     user -> {:ok, user}
  #   end
  # end

  def test_token(email) do
    {:ok, token, _} =
      __MODULE__.encode_and_sign(
        %{"id" => "auth0|" <> Ecto.UUID.generate()},
        %{"https://email" => email}
      )

    {:ok, token}
  end

  # def create_token(user) do
  #   encode_and_sign(user)
  # end

  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    resource = Greenhouse.Accounts.get_user!(id)
    {:ok, resource}
  end
end
