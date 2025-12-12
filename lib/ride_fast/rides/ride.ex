defmodule RideFast.Rides.Ride do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_statuses ~w(SOLICITADA ACEITA EM_ANDAMENTO FINALIZADA CANCELADA)

  schema "rides" do
    field :origin_lat, :float
    field :origin_lng, :float
    field :dest_lat, :float
    field :dest_lng, :float
    field :status, :string, default: "SOLICITADA"
    field :requested_at, :utc_datetime
    field :started_at, :utc_datetime
    field :ended_at, :utc_datetime
    field :price_estimate, :float
    field :final_price, :float

    belongs_to :user, RideFast.Accounts.User
    belongs_to :driver, RideFast.Accounts.Driver
    belongs_to :vehicle, RideFast.Vehicles.Vehicle

    has_one :payment, RideFast.Payments.Payment
    has_many :ratings, RideFast.Ratings.Rating
    has_many :ride_events, RideFast.Rides.RideEvent

    timestamps()
  end

  def changeset(ride, attrs) do
    ride
    |> cast(attrs, [
      :origin_lat, :origin_lng,
      :dest_lat, :dest_lng,
      :status, :requested_at,
      :started_at, :ended_at,
      :price_estimate, :final_price,
      :user_id, :driver_id, :vehicle_id
    ])
    |> validate_required([:origin_lat, :origin_lng, :dest_lat, :dest_lng, :user_id])
    |> validate_inclusion(:status, @valid_statuses)
  end
end
