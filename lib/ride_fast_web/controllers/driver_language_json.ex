defmodule RideFastWeb.DriverLanguageJSON do
  def index(%{languages: languages}) do
    %{data: Enum.map(languages, &language_data/1)}
  end

  def show(%{language: language}) do
    %{data: language_data(language)}
  end

  defp language_data(language) do
    %{
      id: language.id,
      name: language.name,
      code: language.code,
      inserted_at: language.inserted_at
    }
  end
end
