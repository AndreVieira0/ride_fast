defmodule RideFastWeb.LanguageController do
  use RideFastWeb, :controller
  alias RideFast.Languages
  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/languages (público)
  def index(conn, _params) do
    languages = Languages.list_languages()
    render(conn, :index, languages: languages)
  end

  # POST /api/v1/languages (admin only)
  def create(conn, %{"language" => language_params}) do
    with {:ok, language} <- Languages.create_language(language_params) do
      conn
      |> put_status(:created)
      |> render(:show, language: language)
    end
  end

  # PUT /api/v1/languages/:id (admin only)
  def update(conn, %{"id" => id, "language" => language_params}) do
    language = Languages.get_language!(id)

    with {:ok, language} <- Languages.update_language(language, language_params) do
      render(conn, :show, language: language)
    end
  end

  # DELETE /api/v1/languages/:id (admin only)
  def delete(conn, %{"id" => id}) do
    language = Languages.get_language!(id)

    with {:ok, _} <- Languages.delete_language(language) do
      send_resp(conn, :no_content, "")
    end
  end

  # VIEWS
  def render("index.json", %{languages: languages}) do
    %{data: Enum.map(languages, &render_language/1)}
  end

  def render("show.json", %{language: language}) do
    render_language(language)
  end

  defp render_language(language) do
    %{
      id: language.id,
      code: language.code,
      name: language.name,
      inserted_at: language.inserted_at
    }
  end
end
