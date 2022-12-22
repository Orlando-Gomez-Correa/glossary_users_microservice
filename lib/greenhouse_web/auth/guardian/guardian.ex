defmodule GreenhouseWeb.Auth.Guardian.Guardian do
  use Guardian, otp_app: :greenhouse
  alias Greenhouse.Repo
  alias Greenhouse.Accounts.User

  def subject_for_token(user, _claims) do
    {:ok, to_string(user["id"])}
  end

  def resource_from_claims(%{"https://email" => email}) do
    Repo.get_by(User, email: email)
    |> case do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def test_token(email) do
    {:ok, token, _} =
      __MODULE__.encode_and_sign(
        %{"id" => "auth0|" <> Ecto.UUID.generate()},
        %{"https://email" => email}
      )

    {:ok, token}
  end
end
