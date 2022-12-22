defmodule Greenhouse.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Greenhouse.Accounts` context.
  """

  @doc """
  Generate a unique user auth0_id.
  """
  def unique_user_auth0_id, do: "some auth0_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique user email.
  """
  def unique_user_email, do: "some email#{System.unique_integer([:positive])}"

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        auth0_id: unique_user_auth0_id(),
        birthday: "some birthday",
        email: unique_user_email(),
        image: "some image",
        is_admin: true,
        language: "some language",
        lastname: "some lastname",
        middlename: "some middlename",
        name: "some name",
        phone: "some phone",
        second_lastname: "some second_lastname",
        timezone: "some timezone"
      })
      |> Greenhouse.Accounts.create_user()

    user
  end
end
