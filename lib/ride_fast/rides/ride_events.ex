defmodule RideFast.Rides.RideEvents do
  import Ecto.Query
  alias RideFast.Repo
  alias RideFast.Rides.RideEvent

  def create_event(attrs), do: %RideEvent{} |> RideEvent.changeset(attrs) |> Repo.insert()

  def list_by_ride(ride_id), do:
    from(e in RideEvent, where: e.ride_id == ^ride_id, order_by: e.inserted_at)
    |> Repo.all()
end
