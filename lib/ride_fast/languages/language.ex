defmodule RideFast.Languages.Language do
  use Ecto.Schema
  import Ecto.Changeset

  schema "languages" do
    field :code, :string
    field :name, :string

    many_to_many :drivers, RideFast.Accounts.Driver,
      join_through: "drivers_languages",
      on_delete: :delete_all

    timestamps()
  end

  def changeset(language, attrs) do
    language
    |> cast(attrs, [:code, :name])
    |> validate_required([:code, :name])
    |> unique_constraint(:code)
  end
end
