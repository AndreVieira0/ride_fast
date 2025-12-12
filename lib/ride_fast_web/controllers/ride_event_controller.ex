defmodule RideFastWeb.RideEventController do
  use RideFastWeb, :controller
  alias RideFast.Rides.RideEvents

  def index(conn, %{"ride_id" => ride_id}) do
    events = RideEvents.list_by_ride(ride_id)
    json(conn, events)
  end
end
