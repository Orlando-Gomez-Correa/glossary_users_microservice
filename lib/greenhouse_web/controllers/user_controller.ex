defmodule GreenhouseWeb.UserController do
  use GreenhouseWeb, :controller

  alias Greenhouse.Accounts
  alias Greenhouse.Shared.EmailServer
  # alias Greenhouse.Repo
  use PhoenixSwagger

  action_fallback GreenhouseWeb.FallbackController

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")
          description("A user of the application")

          properties do
            id(:string, "User ID")
            auth0_id(:string, "User ID in Auth0", required: false)
            name(:string, "User name", required: true)
            middlename(:string, "User middlename", required: false)
            lastname(:string, "User lastname", required: true)
            second_lastname(:string, "User second lastname", required: false)
            phone(:string, "User phone", required: true)
            birthday(:string, "User birthday", required: false)
            email(:string, "Email address", format: :email, required: true)
            is_admin(:boolean, "User name", required: true)
            image(:string, "User name", required: false)
            language(:string, "User language", required: false)
            timezone(:string, "User timezone", required: false)
            inserted_at(:string, "When was the activity initially inserted", format: :datetime)
            updated_at(:string, "When was the activity last updated", format: :datetime)
          end

          example(%{
            auth0_id: "auth0|63a07963aacda015264805a3",
            birthday: "29/Oct/2000",
            email: "denissefc1@gmail.com",
            id: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd",
            image: %{
              file_name: "avatar_mujer.png",
              updated_at: "2022-12-16T15:55:28"
            },
            inserted_at: "2022-12-16T15:55:28.538401",
            is_admin: true,
            language: "spanish",
            lastname: "Resendiz",
            middlename: "Karina",
            name: "Alondra",
            phone: "+524271145588",
            second_lastname: "Alvarez",
            timezone: "UTC/GMT -6 hours Mexico Guadalajara",
            updated_at: "2022-12-16T15:55:28.538401"
          })
        end,
      UserRequest:
        swagger_schema do
          title("UserRequest")
          description("POST body for creating a user")
          property(:user, Schema.ref(:User), "The user details")
        end,
      UserResponse:
        swagger_schema do
          title("UserResponse")
          description("Response schema for single user")
          property(:data, Schema.ref(:User), "The user details")
        end,
      UsersResponse:
        swagger_schema do
          title("UsersReponse")
          description("Response schema for multiple users")
          property(:data, Schema.array(:User), "The users details")
        end,
      Error:
        swagger_schema do
          title("Errors")
          description("Error responses from the API")

          properties do
            error(:string, "The message of the error raised", required: true)
          end
        end
    }
  end

  swagger_path :create do
    post("/api/users")
    summary("Create user")
    description("Creates a new user")
    consumes("application/json")
    produces("application/json")

    parameter(:user, :body, Schema.ref(:UserRequest), "The user details",
      example: %{
        user: %{
          name: "Alondra",
          middlename: "Karina",
          lastname: "Resendiz",
          second_lastname: "Alvarez",
          phone: "+524271145588",
          birthday: "15/Nov/2000",
          email: "gomez.c.orlando@gmail.com",
          is_admin: "true",
          image: "/home/orlando/Pictures/avatar_mujer.png",
          timezone: "UTC/GMT -6 hours Mexico Guadalajara",
          language: "spanish"
        }
      }
    )

    response(201, "User created OK", Schema.ref(:UserResponse))

    response(422, "Unprocessable Entity", Schema.ref(:Error))
  end

  def create(conn, params) do
    with {:ok, user} <- Accounts.create_user(params),
         {:ok, _email} <- EmailServer.send_inserted_user(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show_user, user))
      |> render("show.json", %{user: user})
    end
  end

  def create_password(conn, %{"token" => token} = params) do
    with {:ok, user_from_token} <-
           Phoenix.Token.verify(GreenhouseWeb.Endpoint, "Confirmation", token,
             max_age: 60 * 60 * 24
           ),
         user <- Accounts.get_user(user_from_token.id),
         {:ok, _updated_user} <- Accounts.validate_password(user, params) do
      conn
      |> put_status(205)
      |> json(%{success: true, message: "User confirmed"})
    else
      {:error, _error} ->
        conn
        |> put_status(400)
        |> json(%{error: "Not token found"})
        |> IO.inspect()

      %Ecto.Changeset{} ->
        conn
        |> put_status(400)
        |> json(%{error: "Bad request"})
    end
  end

  def create_password(conn, _params) do
    conn
    |> put_status(400)
    |> json(%{error: "Bad request create password"})
  end

  def update(conn, params) do
    user = Accounts.get_user!(conn.path_params["id"])

    with {:ok, user} <- Accounts.update_user(user, params) do
      render(conn, "show.json", %{user: user})
    else
      {:error, _error} ->
        conn
        |> put_status(400)
        |> json(%{error: "Bad Request"})
        |> IO.inspect()
    end
  end

  def updateUserAuth(conn, params) do
    with user <- Accounts.get_user!(params) do
      Accounts.update_userAuth(user)

      conn
      |> render("show.json", user: Accounts.get_user(user))
    end
  end

  def delete(conn, %{"id" => id}) do
    with user <- Accounts.get_user!(id) do
      Accounts.delete_user(user)

      conn
      |> send_resp(:no_content, "")
    else
      nil ->
        conn
        |> put_status(404)
        |> render(ErrorView, "404.json", error: "Not found")
    end
  end

  swagger_path(:show_user) do
    get("/api/users/{id}")
    summary("Show User")
    description("Show a user by ID")
    produces("application/json")

    parameter(:id, :path, :string, "User ID",
      required: true,
      example: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd"
    )

    response(200, "OK", Schema.ref(:UserResponse),
      example: %{
        data: %{
          auth0_id: "auth0|63a07963aacda015264805a3",
          birthday: "29/Oct/2000",
          email: "denissefc1@gmail.com",
          id: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd",
          image: %{
            file_name: "avatar_mujer.png",
            updated_at: "2022-12-16T15:55:28"
          },
          inserted_at: "2022-12-16T15:55:28.538401",
          is_admin: true,
          language: "spanish",
          lastname: "Resendiz",
          middlename: "Karina",
          name: "Alondra",
          phone: "+524271145588",
          second_lastname: "Alvarez",
          timezone: "UTC/GMT -6 hours Mexico Guadalajara",
          updated_at: "2022-12-16T15:55:28.538401"
        }
      }
    )

    response(404, "Not found", Schema.ref(:Error))
  end

  def show_user(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    case user != [] do
      true ->
        conn
        |> put_status(:ok)
        |> render("show.json", user: Accounts.get_user(id))

      false ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Not found"})
    end
  end

  swagger_path(:index) do
    get("/api/users?page={page}&page_size={size}")
    summary("List all recorded activities")
    description("List all users in the database")
    produces("application/json")
    deprecated(false)
    parameter(:page, :path, :integer, "Page number to be displayed", required: true, example: 2)

    parameter(:size, :path, :integer, "Total number of entries per page",
      required: true,
      example: 10
    )

    response(200, "OK", Schema.ref(:UsersResponse),
      example: %{
        data: [
          %{
            auth0_id: "auth0|63a07963aacda015264805a3",
            birthday: "29/Oct/2000",
            email: "denissefc1@gmail.com",
            id: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd",
            image: %{
              file_name: "avatar_mujer.png",
              updated_at: "2022-12-16T15:55:28"
            },
            inserted_at: "2022-12-16T15:55:28.538401",
            is_admin: true,
            language: "spanish",
            lastname: "Resendiz",
            middlename: "Karina",
            name: "Alondra",
            phone: "+524271145588",
            second_lastname: "Alvarez",
            timezone: "UTC/GMT -6 hours Mexico Guadalajara",
            updated_at: "2022-12-16T15:55:28.538401"
          },
          %{
            auth0_id: "auth0|895a07963aacda015264805a3",
            birthday: "14/Nov/2000",
            email: "ariel.ti19@gmail.com",
            id: "3d47122c-295c-466a-a3b8-c78c2145170d",
            image: %{
              file_name: "avatar_hombre.png",
              updated_at: "2022-12-08T18:15:39"
            },
            inserted_at: "2022-12-08T18:15:39.367744",
            is_admin: false,
            language: "spanish",
            lastname: "Perez",
            middlename: "Ariel",
            name: "Carlos",
            phone: "+524271127755",
            second_lastname: "Cantero",
            timezone: "UTC/GMT -6 hours",
            updated_at: "2022-12-08T18:15:39.367744"
          }
        ]
      }
    )

    response(202, "Accepted", Schema.ref(:Error),
      example: %{
        data: %{
          error: "There are no users"
        }
      }
    )
  end

  def index(conn, params) do
    page = params["page"] || 1
    page_size = params["page_size"] || 1
    users = Accounts.list_users(:paged, page, page_size)

    case users != [] do
      true ->
        total_count = Accounts.count_users()

        conn
        |> put_status(:ok)
        |> render("index.json", %{
          page: page,
          page_size: page_size,
          total_count: total_count,
          users: users
        })

      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no users"})
    end
  end

  def search_user(conn, %{"name" => name}) do
    users = Accounts.search(name)
    render(conn, "search.json", users: users)
  end

  def upload_avatar(conn, params) do
    user = Accounts.get_user!(conn.path_params["id"])

    with {:ok, user} <- Accounts.update_user_avatar(user, params) do
      render(conn, "show.json", %{user: user})
    else
      {:error, _error} ->
        conn
        |> put_status(400)
        |> json(%{error: "Bad Request"})
        |> IO.inspect()
    end
  end
end
