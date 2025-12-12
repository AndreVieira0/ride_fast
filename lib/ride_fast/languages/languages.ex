defmodule RideFast.Languages do
  @moduledoc """
  Contexto responsável por:
  - Idiomas disponíveis no sistema
  - Associação N:N entre Drivers e Languages
  """

  import Ecto.Query  # ← ADICIONAR ESTA LINHA
  alias RideFast.Repo

  alias RideFast.Languages.{
    Language,
    DriverLanguage
  }

  alias RideFast.Accounts.Driver

  # ==========================
  # LISTAR TODAS AS LÍNGUAS
  # ==========================
  def list_languages do
    Repo.all(Language)
  end

  # ==========================
  # CRIAR NOVO IDIOMA (ADMIN)
  # ==========================
  def create_language(attrs) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  # ==========================
  # LISTAR IDIOMAS DE UM DRIVER
  # ==========================
  def list_driver_languages(driver_id) do
    from(l in Language,
      join: dl in DriverLanguage,
      on: l.id == dl.language_id,
      where: dl.driver_id == ^driver_id
    )
    |> Repo.all()
  end

  # ==========================
  # ASSOCIAR LÍNGUA AO DRIVER
  # ==========================
  def add_language_to_driver(driver_id, language_id) do
    %DriverLanguage{}
    |> DriverLanguage.changeset(%{
      driver_id: driver_id,
      language_id: language_id
    })
    |> Repo.insert()
  end

  # ==========================
  # REMOVER LÍNGUA DO DRIVER
  # ==========================
  def remove_language_from_driver(driver_id, language_id) do
    query =
      from(dl in DriverLanguage,
        where: dl.driver_id == ^driver_id and dl.language_id == ^language_id
      )

    case Repo.one(query) do
      nil ->
        {:error, :not_found}

      driver_language ->
        Repo.delete(driver_language)
    end
  end
end
