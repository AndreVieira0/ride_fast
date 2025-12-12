defmodule RideFast.Rides do
  import Ecto.Query
  alias RideFast.Repo
  alias Ecto.Multi
  alias RideFast.Rides.{Ride, RideEvent}
  alias RideFast.Payments.Payment

  def list_rides(filters \\ %{}) do
    Ride
    |> apply_filters(filters)
    |> Repo.all()
  end

  def get_ride!(id) do
    Ride
    |> Repo.get!(id)
    |> Repo.preload([:user, :driver, :vehicle, :payment, :ratings])
  end

  def request_ride(user_id, attrs) do
    attrs =
      attrs
      |> Map.put("user_id", user_id)
      |> Map.put("status", "SOLICITADA")
      |> Map.put("requested_at", DateTime.utc_now())

    Multi.new()
    |> Multi.insert(:ride, Ride.changeset(%Ride{}, attrs))
    |> Multi.insert(:event, fn %{ride: ride} ->
      RideEvent.changeset(%RideEvent{}, %{
        ride_id: ride.id,
        from_state: nil,
        to_state: "SOLICITADA",
        actor_id: user_id,
        actor_role: "user"
      })
    end)
    |> Repo.transaction()
  end

  def accept_ride(ride_id, driver_id, vehicle_id) do
    Multi.new()
    |> Multi.run(:lock, fn repo, _ ->
      case repo.get(Ride, ride_id, lock: "FOR UPDATE") do
        %Ride{status: "SOLICITADA"} = ride -> {:ok, ride}
        ride -> {:error, {:invalid_state, ride.status}}
      end
    end)
    |> Multi.update(:ride, fn %{lock: ride} ->
      Ride.changeset(ride, %{status: "ACEITA", driver_id: driver_id, vehicle_id: vehicle_id})
    end)
    |> Multi.insert(:event, fn %{ride: ride} ->
      RideEvent.changeset(%RideEvent{}, %{
        ride_id: ride.id,
        from_state: "SOLICITADA",
        to_state: "ACEITA",
        actor_id: driver_id,
        actor_role: "driver"
      })
    end)
    |> Repo.transaction()
  end

  def start_ride(ride_id, driver_id) do
    ride = Repo.get!(Ride, ride_id)

    cond do
      ride.status != "ACEITA" -> {:error, {:invalid_state, ride.status}}
      ride.driver_id != driver_id -> {:error, :unauthorized}
      true ->
        Multi.new()
        |> Multi.update(:ride, Ride.changeset(ride, %{status: "EM_ANDAMENTO", started_at: DateTime.utc_now()}))
        |> Multi.insert(:event, fn %{ride: ride} ->
          RideEvent.changeset(%RideEvent{}, %{
            ride_id: ride.id,
            from_state: "ACEITA",
            to_state: "EM_ANDAMENTO",
            actor_id: driver_id,
            actor_role: "driver"
          })
        end)
        |> Repo.transaction()
    end
  end

  def complete_ride(ride_id, driver_id, %{"final_price" => final_price, "payment_method" => method}) do
    ride = Repo.get!(Ride, ride_id)

    cond do
      ride.status != "EM_ANDAMENTO" -> {:error, {:invalid_state, ride.status}}
      ride.driver_id != driver_id -> {:error, :unauthorized}
      true ->
        Multi.new()
        |> Multi.update(:ride, Ride.changeset(ride, %{
          status: "FINALIZADA",
          ended_at: DateTime.utc_now(),
          final_price: final_price
        }))
        |> Multi.insert(:payment, fn %{ride: ride} ->
          Payment.changeset(%Payment{}, %{
            ride_id: ride.id,
            amount: final_price,
            method: method,
            status: "PAID"
          })
        end)
        |> Multi.insert(:event, fn %{ride: ride} ->
          RideEvent.changeset(%RideEvent{}, %{
            ride_id: ride.id,
            from_state: "EM_ANDAMENTO",
            to_state: "FINALIZADA",
            actor_id: driver_id,
            actor_role: "driver"
          })
        end)
        |> Repo.transaction()
    end
  end

  def cancel_ride(ride_id, actor_id, actor_role, reason \\ nil) do
    ride = Repo.get!(Ride, ride_id)

    cond do
      ride.status == "CANCELADA" -> {:error, :already_canceled}
      true ->
        Multi.new()
        |> Multi.update(:ride, Ride.changeset(ride, %{status: "CANCELADA"}))
        |> Multi.insert(:event, fn %{ride: ride} ->
          RideEvent.changeset(%RideEvent{}, %{
            ride_id: ride.id,
            from_state: ride.status,
            to_state: "CANCELADA",
            actor_id: actor_id,
            actor_role: actor_role,
            metadata: %{reason: reason}
          })
        end)
        |> Repo.transaction()
    end
  end

  defp apply_filters(query, %{status: status}), do: from(q in query, where: q.status == ^status)
  defp apply_filters(query, %{user_id: user_id}), do: from(q in query, where: q.user_id == ^user_id)
  defp apply_filters(query, %{driver_id: driver_id}), do: from(q in query, where: q.driver_id == ^driver_id)
  defp apply_filters(query, _), do: query
end

