defmodule Greenhouse.Accounts.User do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @timestamps_opts [type: :naive_datetime_usec]
  @type t :: %__MODULE__{}
  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  @foreign_key_type :binary_id
  schema "users" do
    field :auth0_id, :string
    field(:birthday, :string)
    field(:email, :string)
    field :image, Greenhouse.AvatarUploader.Type
    field(:is_admin, :boolean, default: false)
    field(:language, :string)
    field(:lastname, :string)
    field(:middlename, :string)
    field(:name, :string)
    field(:phone, :string)
    field(:second_lastname, :string)
    field(:timezone, :string)

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [
      :birthday,
      :email,
      :is_admin,
      :language,
      :lastname,
      :middlename,
      :name,
      :phone,
      :second_lastname,
      :timezone
    ])
    |> validate_required([
      :name,
      :lastname,
      :phone,
      :email,
      :is_admin
    ])
    |> validate_format(:name, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> validate_format(:lastname, ~r{^[a-zA-ZÀ-ÿ ]+$})
    |> validate_format(:email, ~r{^[^@]+@[^@]+\.[a-zA-Z]+$}, message: "Type a valid e-mail")
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email, message: "Email already exist")
  end

  def add_auth0_id_changeset(user, attrs) do
    user
    |> cast(attrs, [:auth0_id])
    |> validate_required([:auth0_id])
  end

  def update_user_password(user, attrs) do
    user
    |> cast(attrs, [:password, :password_confirmation])
    |> validate_required([:password, :password_confirmation])
    |> validate_confirmation(:password)
    |> validate_required([:password, :password_confirmation])
    |> validate_format(:password, ~r{^(?=\w*\d)(?=\w*[A-Z])(?=\w*[a-z])\S+$},
      message: "Type a valid password"
    )
    |> validate_length(:password, min: 8, message: "Password is to short")
    |> validate_confirmation(:password)
  end

  def avatar_changeset(user, attrs) do
    user
    |> cast(attrs, [:image])
    |> cast_attachments(attrs, [:image], allow_paths: true)
  end
end
