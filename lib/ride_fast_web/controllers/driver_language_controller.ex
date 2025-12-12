defmodule RideFastWeb.DriverLanguageController do
  use RideFastWeb, :controller
  alias RideFast.Languages
  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers/:driver_id/languages (público)
  def index(conn, %{"driver_id" => driver_id}) do
    languages = Languages.list_driver_languages(driver_id)
    render(conn, :index, languages: languages)
  end

  # POST /api/v1/drivers/:driver_id/languages/:language_id
  def create(conn, %{"driver_id" => driver_id, "language_id" => language_id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        if current_user.role == "admin" or current_user.id == String.to_integer(driver_id) do
          with {:ok, _} <- Languages.add_language_to_driver(driver_id, language_id) do
            conn
            |> put_status(:created)
            |> json(%{message: "Language added"})
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # DELETE /api/v1/drivers/:driver_id/languages/:language_id
  def delete(conn, %{"driver_id" => driver_id, "language_id" => language_id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        if current_user.role == "admin" or current_user.id == String.to_integer(driver_id) do
          case Languages.remove_language_from_driver(driver_id, language_id) do
            {1, _} ->
              send_resp(conn, :no_content, "")

            _ ->
              conn
              |> put_status(:not_found)
              |> json(%{error: "Association not found"})
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # VIEW (mantido igual)
  def render("index.json", %{languages: languages}) do
    %{data: Enum.map(languages, &render_language/1)}
  end

  defp render_language(language) do
    %{
      id: language.id,
      code: language.code,
      name: language.name
    }
  end
end