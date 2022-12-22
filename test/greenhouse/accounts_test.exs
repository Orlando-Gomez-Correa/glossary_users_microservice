defmodule Greenhouse.AccountsTest do
  use Greenhouse.DataCase

  alias Greenhouse.Accounts

  describe "users" do
    alias Greenhouse.Accounts.User

    import Greenhouse.AccountsFixtures

    @invalid_attrs %{auth0_id: nil, birthday: nil, email: nil, image: nil, is_admin: nil, language: nil, lastname: nil, middlename: nil, name: nil, phone: nil, second_lastname: nil, timezone: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{auth0_id: "some auth0_id", birthday: "some birthday", email: "some email", image: "some image", is_admin: true, language: "some language", lastname: "some lastname", middlename: "some middlename", name: "some name", phone: "some phone", second_lastname: "some second_lastname", timezone: "some timezone"}

      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.auth0_id == "some auth0_id"
      assert user.birthday == "some birthday"
      assert user.email == "some email"
      assert user.image == "some image"
      assert user.is_admin == true
      assert user.language == "some language"
      assert user.lastname == "some lastname"
      assert user.middlename == "some middlename"
      assert user.name == "some name"
      assert user.phone == "some phone"
      assert user.second_lastname == "some second_lastname"
      assert user.timezone == "some timezone"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{auth0_id: "some updated auth0_id", birthday: "some updated birthday", email: "some updated email", image: "some updated image", is_admin: false, language: "some updated language", lastname: "some updated lastname", middlename: "some updated middlename", name: "some updated name", phone: "some updated phone", second_lastname: "some updated second_lastname", timezone: "some updated timezone"}

      assert {:ok, %User{} = user} = Accounts.update_user(user, update_attrs)
      assert user.auth0_id == "some updated auth0_id"
      assert user.birthday == "some updated birthday"
      assert user.email == "some updated email"
      assert user.image == "some updated image"
      assert user.is_admin == false
      assert user.language == "some updated language"
      assert user.lastname == "some updated lastname"
      assert user.middlename == "some updated middlename"
      assert user.name == "some updated name"
      assert user.phone == "some updated phone"
      assert user.second_lastname == "some updated second_lastname"
      assert user.timezone == "some updated timezone"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end
end
