defmodule GreenhouseWeb.UserView do
  use GreenhouseWeb, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, __MODULE__, "user.json")}
  end

  def render("index.json", %{
        users: users,
        total_count: total_count,
        page: page,
        page_size: page_size
      }) do
    %{
      total_count: total_count,
      page: page,
      page_size: page_size,
      users: render_many(users, __MODULE__, "user.json")
    }
  end

  # def render("search.json", %{
  #       users: users
  #     }) do
  #   %{
  #     users: render_many(users, __MODULE__, "user.json")
  #   }
  # end

  def render("search.json", %{users: users}) do
    %{data: render_many(users, __MODULE__, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      middlename: user.middlename,
      lastname: user.lastname,
      second_lastname: user.second_lastname,
      phone: user.phone,
      email: user.email,
      birthday: user.birthday,
      is_admin: user.is_admin,
      image: user.image,
      timezone: user.timezone,
      language: user.language,
      auth0_id: user.auth0_id,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end
