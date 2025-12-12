defmodule RideFastWeb.ErrorView do
  import Plug.Conn

  def render("404.json", _assigns), do: %{error: "Not found"}
  def render("500.json", _assigns), do: %{error: "Internal server error"}

  def render("error.json", %{reason: reason}), do: %{error: reason}

  def template_not_found(_template, _assigns), do: %{error: "Unknown error"}
end
