defmodule GreenhouseWeb.UserController do
  use GreenhouseWeb, :controller

  alias Greenhouse.Accounts
  alias Greenhouse.Shared.EmailServer
  alias GreenhouseWeb.Auth.Guardian.Guardian

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
      CreateUserRequest:
        swagger_schema do
          title("CreateUserRequest")
          description("POST body for creating a user")
          property(:user, Schema.ref(:User), "The user details")

          example(%{
            name: "Alondra",
            middlename: "Karina",
            lastname: "Resendiz",
            second_lastname: "Alvarez",
            phone: "+524271145588",
            birthday: "15/Nov/2000",
            email: "karina@gmail.com",
            is_admin: "true",
            timezone: "UTC/GMT -6 hours Mexico Guadalajara",
            language: "spanish"
          })
        end,
      CreateUserResponse:
        swagger_schema do
          title("CreateUserResponse")
          description("Response schema for single user")
          property(:data, Schema.ref(:User), "The user details created")

          example(%{
            data: %{
              auth0_id: "auth0|63a07963aacda015264805a3",
              birthday: "15/Nov/2000",
              email: "karina@gmail.com",
              id: "e9bd02f8-f81a-4e4b-b67c-86df37b4ff1a",
              image: %{
                file_name: "avatar_mujer.png",
                updated_at: "2022-12-16T15:55:28"
              },
              inserted_at: "2022-12-23T18:11:08.671904",
              is_admin: true,
              language: "spanish",
              lastname: "Resendiz",
              middlename: "Karina",
              name: "Alondra",
              phone: "+524271145588",
              second_lastname: "Alvarez",
              timezone: "UTC/GMT -6 hours Mexico Guadalajara",
              updated_at: "2022-12-23T18:11:08.671904"
            }
          })
        end,
      CreateUserResponseErrors:
        swagger_schema do
          title("CreateUserResponseErrors")
          description("Response errors from create user")

          example(%{
            name: "can't be blank",
            email: "can't be blank"
          })
        end,
      ShowUsersResponse:
        swagger_schema do
          title("ShowUsersResponse")
          description("Response schema for multiple users created")
          property(:data, Schema.array(:User), "The users details")

          example(%{
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
          })
        end,
      ShowUsersEmptyResponse:
        swagger_schema do
          title("ShowUsersEmptyResponse")
          description("Response error users empty")

          example(%{
            error: "There are no users"
          })
        end,
      ShowUserResponse:
        swagger_schema do
          title("ShowUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.ref(:User), "The user found")

          example(%{
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
          })
        end,
      UpdateUserRequest:
        swagger_schema do
          title("UpdateUserRequest")
          description("Request params to update a user")
          property(:data, Schema.array(:User), "The user params")

          example(%{
            name: "Denisse"
          })
        end,
      UpdateUserResponse:
        swagger_schema do
          title("UpdateUserResponse")
          description("Response schema of a single user")
          property(:data, Schema.array(:User), "The user updated")

          example(%{
            data: %{
              name: "Denisse",
              middlename: "Karina",
              lastname: "Resendiz",
              second_lastname: "Alvarez",
              phone: "+524271145588",
              birthday: "15/Nov/2000",
              email: "karina@gmail.com",
              is_admin: "true",
              image: %{
                file_name: "avatar_mujer.png",
                updated_at: "2022-12-16T15:55:28"
              },
              timezone: "UTC/GMT -6 hours Mexico Guadalajara",
              language: "spanish"
            }
          })
        end,
      DeleteUserRequest:
        swagger_schema do
          title("DeleteUserRequest")
          description("Request params to delete a user")
        end,
      DeleteUserResponse:
        swagger_schema do
          title("DeleteUserResponse")
          description("Response schema of a single user")
          property(:users, Schema.array(:User), "The user deleted")

          example(%{
            data: %{
              name: "Denisse",
              middlename: "Karina",
              lastname: "Resendiz",
              second_lastname: "Alvarez",
              phone: "+524271145588",
              birthday: "15/Nov/2000",
              email: "karina@gmail.com",
              is_admin: "true",
              image: %{
                file_name: "avatar_mujer.png",
                updated_at: "2022-12-16T15:55:28"
              },
              timezone: "UTC/GMT -6 hours Mexico Guadalajara",
              language: "spanish"
            }
          })
        end,
      UpdateAvatarUserRequest:
        swagger_schema do
          title("UpdateAvatarUserRequest")
          description("Request params to update a user's image")
          property(:data, Schema.array(:User), "The user params")

          example(%{
            image: "Denisse"
          })
        end,
      UpdateAvatarUserResponse:
        swagger_schema do
          title("UpdateAvatarUserResponse")
          description("Response schema of a single user")
          property(:data, Schema.array(:User), "The user updated")

          example(%{
            data: %{
              name: "Denisse",
              middlename: "Karina",
              lastname: "Resendiz",
              second_lastname: "Alvarez",
              phone: "+524271145588",
              birthday: "15/Nov/2000",
              email: "karina@gmail.com",
              is_admin: "true",
              image: %{
                file_name: "avatar_mujer.png",
                updated_at: "2022-12-16T15:55:28"
              },
              timezone: "UTC/GMT -6 hours Mexico Guadalajara",
              language: "spanish"
            }
          })
        end,
      CreateUserPasswordRequest:
        swagger_schema do
          title("CreateUserPasswordRequest")
          description("POST body for creating a user password")
          property(:user, Schema.ref(:User), "The user password details")

          example(%{
            token:
              "SFMyNTY.g2gDdAAAABJkAAhfX21ldGFfX3QAAAAGZAAKX19zdHJ1Y3RfX2QAG0VsaXhpci5FY3RvLlNjaGVtYS5NZXRhZGF0YWQAB2NvbnRleHRkAANuaWxkAAZwcmVmaXhkAANuaWxkAAZzY2hlbWFkAB9FbGl4aXIuR3JlZW5ob3VzZS5BY2NvdW50cy5Vc2VyZAAGc291cmNlbQAAAAV1c2Vyc2QABXN0YXRlZAAGbG9hZGVkZAAIYXV0aDBfaWRkAANuaWxkAAhiaXJ0aGRheW0AAAALMTUvTm92LzE5OThkAAVlbWFpbG0AAAAZZ29tZXouYy5vcmxhbmRvQGdtYWlsLmNvbWQAAmlkbQAAACQ4NTFmZTM2OC1jMzQ1LTRlYzQtODAyOS1lMTdhMDM0YjMxNGFkAAVpbWFnZWQAA25pbGQAC2luc2VydGVkX2F0dAAAAAlkAApfX3N0cnVjdF9fZAAURWxpeGlyLk5haXZlRGF0ZVRpbWVkAAhjYWxlbmRhcmQAE0VsaXhpci5DYWxlbmRhci5JU09kAANkYXlhFmQABGhvdXJhEGQAC21pY3Jvc2Vjb25kaAJiAAXzn2EGZAAGbWludXRlYQVkAAVtb250aGEMZAAGc2Vjb25kYQdkAAR5ZWFyYgAAB-ZkAAhpc19hZG1pbmQABHRydWVkAAhsYW5ndWFnZW0AAAAHc3BhbmlzaGQACGxhc3RuYW1lbQAAAAVHb21lemQACm1pZGRsZW5hbWVkAANuaWxkAARuYW1lbQAAAAdPcmxhbmRvZAAIcGFzc3dvcmRkAANuaWxkABVwYXNzd29yZF9jb25maXJtYXRpb25kAANuaWxkAAVwaG9uZW0AAAANKzUyNDI3ODg4OTkyMWQAD3NlY29uZF9sYXN0bmFtZW0AAAAGQ29ycmVhZAAIdGltZXpvbmVtAAAAI1VUQy9HTVQgLTYgaG91cnMgTWV4aWNvIEd1YWRhbGFqYXJhZAAKdXBkYXRlZF9hdHQAAAAJZAAKX19zdHJ1Y3RfX2QAFEVsaXhpci5OYWl2ZURhdGVUaW1lZAAIY2FsZW5kYXJkABNFbGl4aXIuQ2FsZW5kYXIuSVNPZAADZGF5YRZkAARob3VyYRBkAAttaWNyb3NlY29uZGgCYgAF859hBmQABm1pbnV0ZWEFZAAFbW9udGhhDGQABnNlY29uZGEHZAAEeWVhcmIAAAfmbgYAv8iUOoUBYgABUYA.FFYVgzcyfMGilXtwq2wKQe0GmweDw5ARC-UA7jNZodo",
            password: "C0c@C0l@7952",
            password_confirmation: "C0c@C0l@7952"
          })
        end,
      CreateUserPasswordRespond:
        swagger_schema do
          title("CreateUserPasswordRespond")
          description("Response schema for user password confirm")
          property(:data, Schema.ref(:User), "The user details created")

          example(%{
            message: "User confirmed",
            success: true
          })
        end,
      CreateUserPasswordRespondErrors:
        swagger_schema do
          title("CreateUserPasswordRespondErrors")
          description("Response errors from create user")

          example(%{
            token: "can't be blank",
            password: "can't be blank",
            password_confirmation: "can't be blank"
          })
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
    summary("Add a new user")
    description("Create a new user in the database")
    consumes("application/json")
    produces("application/json")
    deprecated(false)

    parameter(:user, :body, Schema.ref(:CreateUserRequest), "The user data", required: true)

    response(201, "Created", Schema.ref(:CreateUserResponse))
    response(400, "Bad Request", Schema.ref(:CreateUserResponseErrors))
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

  swagger_path :create_password do
    post("/api/users/confirmation")
    summary("Add the password for a new user")
    description("Create a password in Auth0 for a new user in the database")
    consumes("application/json")
    produces("application/json")
    deprecated(false)

    parameter(:user, :body, Schema.ref(:CreateUserPasswordRequest), "The user data",
      required: true
    )

    response(201, "Created", Schema.ref(:CreateUserPasswordRespond))
    response(400, "Bad Request", Schema.ref(:CreateUserPasswordRespondErrors))
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

  swagger_path(:update) do
    put("/api/users/{id}/update")

    summary("Update a user")
    description("Update all attributes of a user")
    consumes("application/json")
    produces("application/json")

    parameters do
      id(:path, :string, "The id of the user",
        required: true,
        example: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd"
      )

      user(:body, Schema.ref(:UpdateUserRequest), "The user details to update", required: true)
    end

    response(205, "Updated", Schema.ref(:UpdateUserResponse))
    response(400, "Unprocessable Entity", Schema.ref(:Error))
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

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/users/{id}")
    summary("Delete a Specific User")
    description("Delete a user by ID")

    parameter(:id, :path, :string, "User ID",
      required: true,
      example: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd"
    )

    response(204, "No Content - Deleted Successfully")
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
    summary("Show a Specific User")
    description("Return JSON with an especific user")
    produces("application/json")
    deprecated(false)

    parameter(:id, :path, :string, "User ID",
      required: true,
      example: "1b1716bd-1875-44c4-8c4b-6f969fc5fdbd"
    )

    response(200, "User created OK", Schema.ref(:ShowUserResponse))

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
    summary("All Users")
    description("Return JSON with all users listed in the database")
    produces("application/json")
    deprecated(false)

    parameters do
      page(:path, :integer, "Page number to be displayed", required: true, example: 2)

      size(:path, :integer, "Total number of entries per page",
        required: true,
        example: 10
      )
    end

    response(200, "Success", Schema.ref(:ShowUsersResponse))
    response(204, "No users", Schema.ref(:ShowUsersEmptyResponse))
  end

  def index(conn, params) do
    page = params["page"] || 1
    page_size = params["page_size"] || 1

    users = Accounts.list_users(:paged, page, page_size)

    case users != [] do
      true ->
        conn
        |> put_status(:ok)
        |> render("index.json", users: users)

      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no users"})
    end
  end

  swagger_path(:search_user) do
    get("/api/users?name={name}")
    summary("All Users in the search")
    description("Returns JSON with all users matching listed in the database")
    produces("application/json")
    deprecated(false)

    parameters do
      name(:path, :string, "The field you want to find", required: true)
    end

    response(200, "Success", Schema.ref(:ShowUsersResponse))
    response(204, "No users", Schema.ref(:ShowUsersEmptyResponse))
  end

  def search_user(conn, params) do
    page = params["page"] || 1
    page_size = params["page_size"] || 1
    term = params["name"]
    users = Accounts.list_search_users(:paged, page, page_size, term)

    case users != [] do
      true ->
        conn
        |> put_status(:ok)
        |> render("index.json", users: users)

      false ->
        conn
        |> put_status(200)
        |> json(%{error: "There are no users"})
    end
  end

  swagger_path :upload_avatar do
    put("/users/upload_avatar/{id}")
    summary("Upload avatar of a user")
    description("Update the user's profile picture")
    consumes("multipart/form-data")
    produces("multipart/form-data")

    parameters do
      id(:path, :string, "User ID", required: true)
      image(:file, :formData, "Browse File", required: true)
    end

    response(201, "Ok", Schema.ref(:UpdateAvatarUserResponse))
    response(422, "Unprocessable Entity", Schema.ref(:Error))
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

  def show_image(conn, %{"image" => image}) do
    file = File.read!("uploads/#{image}")

    conn
    |> put_status(200)
    |> send_resp(:ok, file)
  end

  def send_reset_password(conn, params) do
    with {:ok, user} <- Accounts.create_user(params),
         {:ok, _email} <- EmailServer.send_inserted_user(user) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.user_path(conn, :show_user, user))
      |> render("show.json", %{user: user})
    end
  end

  def createTest(conn, params) do
    with {:ok, user} <- Accounts.create_user(params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      conn |> render("jwt.json", jwt: token)
    end
  end

  def showTest(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    conn |> render("user.json", user: user)
  end

  #   def create(conn, %{"user" => user_params}) do
  #   with {:ok, %User{} = user} <- Accounts.create_user(user_params),
  #        {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
  #     conn |> render("jwt.json", jwt: token)
  #   end
  # end

  #   def create(conn, params) do
  #   with {:ok, user} <- Accounts.create_user(params),
  #        {:ok, _email} <- EmailServer.send_inserted_user(user) do
  #     conn
  #     |> put_status(:created)
  #     |> put_resp_header("location", Routes.user_path(conn, :show_user, user))
  #     |> render("show.json", %{user: user})
  #   end
  # end
end
