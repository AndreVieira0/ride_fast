defmodule RideFast.Accounts.Driver do
  use Ecto.Schema
  import Ecto.Changeset

  schema "drivers" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :status, :string, default: "active"
    field :password, :string, virtual: true
    field :password_hash, :string

    has_one :profile, RideFast.Accounts.DriverProfile
    has_many :vehicles, RideFast.Vehicles.Vehicle
    has_many :rides, RideFast.Rides.Ride, foreign_key: :driver_id
    has_many :ratings_received, RideFast.Ratings.Rating, foreign_key: :to_driver_id

    many_to_many :languages, RideFast.Languages.Language,
      join_through: "drivers_languages",
      on_delete: :delete_all

    timestamps()
  end

  def registration_changeset(driver, attrs) do
    driver
    |> cast(attrs, [:name, :email, :phone, :password, :status])
    |> validate_required([:name, :email, :phone, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> put_password_hash()
  end

  def update_changeset(driver, attrs) do
    driver
    |> cast(attrs, [:name, :email, :phone, :status])
    |> validate_required([:name, :email, :phone])
    |> unique_constraint(:email)
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
