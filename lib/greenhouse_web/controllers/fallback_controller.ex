defmodule GreenhouseWeb.FallbackController do
  use GreenhouseWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(GreenhouseWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end
end
