defmodule RideFastWeb.LanguageJSON do
  alias RideFast.Languages.Language

  def show(%{language: %Language{} = lang}) do
    %{
      data: %{
        id: lang.id,
        code: lang.code,
        name: lang.name
      }
    }
  end

  def index(%{languages: languages}) do
    %{
      data: Enum.map(languages, fn l ->
        %{
          id: l.id,
          code: l.code,
          name: l.name
        }
      end)
    }
  end
end
