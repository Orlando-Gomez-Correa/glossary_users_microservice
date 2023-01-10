defmodule GreenhouseWeb.Auth.Auth do
  def create_user(name, email, password) do
    {:ok, token} = get_token()

    url = "https://orlando-greenhouse.us.auth0.com/api/v2/users"

    body =
      {:form,
       [
         name: name,
         email: email,
         password: password,
         connection: "Username-Password-Authentication",
         verify_email: false
       ]}

    headers = [{"Authorization", "Bearer #{token}"}, {"Accept", "application/json"}]

    user = HTTPoison.post!(url, body, headers, [])

    case user do
      %HTTPoison.Response{status_code: 201, body: body} ->
        {:ok, Jason.decode!(body)}

      %HTTPoison.Response{status_code: 409, body: body} ->
        {:error, Jason.decode!(body)}

      other ->
        raise "Boom (#{inspect(other)})"
    end
  end

  defp get_token() do
    url = "https://orlando-greenhouse.us.auth0.com/oauth/token"

    body =
      {:form,
       [
         audience: System.get_env("AUTH0_AUDIENCE"),
         client_id: System.get_env("AUTH0_CLIENT_ID"),
         client_secret: System.get_env("AUTH0_CLIENT_SECRET"),
         grant_type: System.get_env("AUTH0_GRANT_TYPE")
       ]}

    headers = [{"Accept", "application/json"}]

    result = HTTPoison.post!(url, body, headers, [])

    case result do
      %HTTPoison.Response{status_code: 200, body: body} ->
        response = Jason.decode!(body)

        {:ok, response["access_token"]}

      other ->
        raise "Boom (#{inspect(other)})"
    end
  end

  def delete_user(auth0_id) do
    {:ok, token} = get_token()

    url = "https://orlando-greenhouse.us.auth0.com/api/v2/users/#{auth0_id}"

    headers = [{"Authorization", "Bearer #{token}"}, {"content-type", "application/json"}]

    HTTPoison.delete!(url, headers, [])
  end

  def update_user(auth0_id, name) do
    {:ok, token} = get_token()

    url = "https://orlando-greenhouse.us.auth0.com/api/v2/users/#{auth0_id}"

    body =
      {:form,
       [
         name: name
       ]}

    headers = [{"Authorization", "Bearer #{token}"}, {"content-type", "application/json"}]

    result = HTTPoison.patch!(url, body, headers, [])

    case result do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, Jason.decode!(body)}

      %HTTPoison.Response{status_code: 404, body: body} ->
        {:error, Jason.decode!(body)}

      other ->
        raise "Boom (#{inspect(other)})"
    end
  end

  def reset_password(auth0_id, password) do
    {:ok, token} = get_token()

    url = "https://orlando-greenhouse.us.auth0.com/api/v2/users/#{auth0_id}"

    body =
      {:form,
       [
         password: password
       ]}

    headers = [{"Authorization", "Bearer #{token}"}, {"content-type", "application/json"}]

    result = HTTPoison.patch!(url, body, headers, [])

    case result do
      %HTTPoison.Response{status_code: 200, body: body} ->
        {:ok, Jason.decode!(body)}

      %HTTPoison.Response{status_code: 404, body: body} ->
        {:error, Jason.decode!(body)}

      other ->
        raise "Boom (#{inspect(other)})"
    end
  end
end
