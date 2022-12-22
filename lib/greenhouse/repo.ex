defmodule Greenhouse.Repo do
  use Ecto.Repo,
    otp_app: :greenhouse,
    adapter: Ecto.Adapters.Postgres

  # use Scrivener, page_size: 5
end
