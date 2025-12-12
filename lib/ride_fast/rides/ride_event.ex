defmodule RideFast.Rides.RideEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ride_events" do
    field :from_state, :string
    field :to_state, :string
    field :actor_id, :integer
    field :actor_role, :string

    belongs_to :ride, RideFast.Rides.Ride

    timestamps()
  end

  def changeset(ride_event, attrs) do
    ride_event
    |> cast(attrs, [:ride_id, :from_state, :to_state, :actor_id, :actor_role])
    |> validate_required([:ride_id, :from_state, :to_state, :actor_id, :actor_role])
  end
end
