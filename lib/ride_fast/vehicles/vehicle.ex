defmodule RideFast.Vehicles.Vehicle do
  use Ecto.Schema
  import Ecto.Changeset

  schema "vehicles" do
    field :plate, :string
    field :model, :string
    field :color, :string
    field :seats, :integer
    field :active, :boolean, default: true

    belongs_to :driver, RideFast.Accounts.Driver

    has_many :rides, RideFast.Rides.Ride

    timestamps()
  end

  def changeset(vehicle, attrs) do
    vehicle
    |> cast(attrs, [:plate, :model, :color, :seats, :active, :driver_id])
    |> validate_required([:plate, :model, :color, :seats, :driver_id])
    |> unique_constraint(:plate)
  end
end
