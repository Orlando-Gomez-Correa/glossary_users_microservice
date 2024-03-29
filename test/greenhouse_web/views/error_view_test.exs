defmodule GreenhouseWeb.ErrorViewTest do
  use GreenhouseWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View

  test "renders 404.json" do
    assert render(GreenhouseWeb.ErrorView, "404.json", []) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500.json" do
    assert render(GreenhouseWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal Server Error"}}
  end

  test "renders 404.json" do
    assert render(GreenhouseWeb.ErrorView, "404.json", []) ==
             %{errors: %{detail: "Page not found"}}
  end

  test "renders 422.json" do
    assert render(GreenhouseWeb.ErrorView, "422.json", []) ==
             %{errors: %{detail: "Bad request"}}
  end

  test "render 500.json" do
    assert render(GreenhouseWeb.ErrorView, "500.json", []) ==
             %{errors: %{detail: "Internal server error"}}
  end

  test "render any other" do
    assert render(GreenhouseWeb.ErrorView, "505.json", []) ==
             %{errors: %{detail: "Internal server error"}}
  end
end
