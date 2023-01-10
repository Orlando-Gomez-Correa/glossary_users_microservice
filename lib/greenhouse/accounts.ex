defmodule Greenhouse.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false

  alias Greenhouse.Repo
  alias Greenhouse.Accounts.User
  alias GreenhouseWeb.Auth.Auth
  import Greenhouse.Guards

  @doc """
  Returns the list of users.
  ## Examples
      iex> list_users()
      [%User{}, ...]
  """

  # def list_users_test(params) do
  #   User
  #   |> order_by(asc: :name)
  #   |> Repo.paginate(params)
  # end

  # def list_users_testing do
  #   Repo.all(User)
  # end

  # def list_users_testing(user = %User{}) do
  #   User
  #   |> where(user_id: ^user.id)
  #   |> Repo.all()

  #   # Repo.all(where(Accounts, name: ^user.id))
  # end

  def list_users(:paged, page, per_page) do
    User
    |> order_by(asc: :name)
    |> __MODULE__.page(page, per_page)
  end

  @doc """
  Gets a single user.
  Raises `Ecto.NoResultsError` if the User does not exist.
  ## Examples
      iex> get_user!(123)
      %User{}
      iex> get_user!(456)
      ** (Ecto.NoResultsError)
  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id) when is_uuid(id) do
    Repo.get(User, id)
  end

  def get_user(_id), do: {:error, :not_found}

  @doc """
  Creates a user.
  ## Examples
      iex> create_user(%{field: value})
      {:ok, %User{}}
      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def create_user(params) do
    %User{}
    |> User.changeset(params)
    |> Repo.insert()
  end

  def auth0_id_update(user, params) do
    user
    |> User.add_auth0_id_changeset(params)
    |> Repo.update()
  end

  def validate_password(user, params) do
    user
    |> User.update_user_password(params)
    |> create_auth0_user(user)
  end

  defp create_auth0_user(%{valid?: false} = changeset, _) do
    changeset
  end

  defp create_auth0_user(%{valid?: true, changes: changes}, user = %User{}) do
    with {:ok, user_auth0} <-
           Auth.create_user("#{user.name} #{user.lastname}", user.email, changes.password),
         {:ok, updated_user} <- auth0_id_update(user, %{auth0_id: user_auth0["user_id"]}) do
      {:ok, updated_user}
    end
  end

  def confirm_password(user, params) do
    user
    |> User.update_user_password(params)
  end

  def reset_password_auth0(%{valid?: false} = changeset, _) do
    changeset
  end

  def reset_password_auth0(%{valid?: true, changes: changes}, user = %User{}) do
    with {:ok, user_auth0} <-
           Auth.reset_password(user.auth0_id, changes.password),
         {:ok, updated_user} <- auth0_id_update(user, %{auth0_id: user_auth0["user_id"]}) do
      {:ok, updated_user}
    end
  end

  @doc """
  Updates a user.
  ## Examples
      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}
      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_userAuth(%User{} = user) do
    Auth.update_user(user.auth0_id, user.name)
  end

  @doc """
  Deletes a user.
  ## Examples
      iex> delete_user(user)
      {:ok, %User{}}
      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}
  """
  def delete_user(%User{} = user) do
    Auth.delete_user(user.auth0_id)
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  ## Examples
      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def update_user_avatar(%User{} = user, attrs) do
    user
    |> User.avatar_changeset(attrs)
    |> Repo.update()
  end

  def change_user_avatar(%User{} = user) do
    User.avatar_changeset(user, %{})
  end

  def query(query, page, per_page) when is_nil(page) do
    query(query, 0, per_page)
  end

  def query(query, page, per_page) when is_nil(per_page) do
    query(query, page, 0)
  end

  def query(query, page, per_page) when is_binary(page) do
    query(query, String.to_integer(page), per_page)
  end

  def query(query, page, per_page) when is_binary(per_page) do
    query(query, page, String.to_integer(per_page))
  end

  def query(query, page, per_page) do
    query
    |> limit(^(per_page + 0))
    |> offset(^(per_page * (page - 1)))
    |> Repo.all()
  end

  def page(query, page, per_page) when is_binary(page) do
    page(query, String.to_integer(page), per_page)
  end

  def page(query, page, per_page) when is_binary(per_page) do
    page(query, page, String.to_integer(per_page))
  end

  def page(query, page, per_page) do
    results = query(query, page, per_page)
    has_next = length(results) > per_page
    has_prev = page > 1
    total_count = Repo.one(from(t in subquery(query), select: count("*")))

    %{
      has_next: has_next,
      has_prev: has_prev,
      prev_page: page - 1,
      page: page,
      next_page: page + 1,
      first: (page - 1) * per_page + 1,
      last: Enum.min([page * per_page, total_count]),
      total_count: total_count,
      list: Enum.slice(results, 0, per_page)
    }
  end

  def list_search_users(:paged, page, per_page, term) do
    search_term = "%#{term}%"

    User
    |> where([u], ilike(u.name, ^search_term))
    |> or_where([u], ilike(u.lastname, ^search_term))
    |> order_by(asc: :name)
    |> __MODULE__.page(page, per_page)
  end
end
