defmodule RideFast.Languages.DriverLanguage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drivers_languages" do
    belongs_to :driver, RideFast.Accounts.Driver
    belongs_to :language, RideFast.Languages.Language

    timestamps()   # ← ADICIONAR AQUI
  end

  def changeset(dl, attrs) do
    dl
    |> cast(attrs, [:driver_id, :language_id])
    |> validate_required([:driver_id, :language_id])
    |> unique_constraint(
         [:driver_id, :language_id],
         name: :drivers_languages_driver_id_language_id_index
       )
  end
end
