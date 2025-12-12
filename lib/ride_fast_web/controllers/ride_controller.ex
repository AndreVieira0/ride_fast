defmodule RideFastWeb.RideController do
  use RideFastWeb, :controller

  import Ecto.Query
  alias RideFast.Repo
  alias RideFast.Rides
  alias RideFast.Rides.Ride
  alias RideFast.Accounts

  action_fallback RideFastWeb.FallbackController

  # ========== LISTAR CORRIDAS ==========
  def index(conn, params) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        filters = %{}
        |> Map.put(:status, params["status"])
        |> Map.put(:user_id, if(current_user.role == "user", do: current_user.id))
        |> Map.put(:driver_id, if(current_user.role == "driver", do: current_user.id))
        |> Enum.reject(fn {_, v} -> is_nil(v) end)
        |> Map.new()

        page = String.to_integer(params["page"] || "1")
        size = String.to_integer(params["size"] || "20")

        query = Rides.list_rides(filters)

        rides =
          query
          |> limit(^size)
          |> offset(^((page - 1) * size))
          |> Repo.all()

        total = Repo.aggregate(query, :count, :id)

        conn
        |> put_status(:ok)
        |> render("index.json", rides: rides, pagination: %{page: page, size: size, total: total})
    end
  end

  # ========== CRIAR CORRIDA (USER) ==========
  def create(conn, %{
        "origin" => %{"lat" => olat, "lng" => olng},
        "destination" => %{"lat" => dlat, "lng" => dlng},
        "payment_method" => payment_method
      }) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      user ->
        if user.role != "user" do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Only users can request rides"})
        else
          attrs = %{
            "origin_lat" => olat,
            "origin_lng" => olng,
            "dest_lat" => dlat,
            "dest_lng" => dlng,
            "payment_method" => payment_method
          }

          case Rides.request_ride(user.id, attrs) do
            {:ok, %{ride: ride}} ->
              conn
              |> put_status(:created)
              |> render("show.json", ride: ride)

            {:error, _, changeset, _} ->
              conn
              |> put_status(:bad_request)
              |> render(RideFastWeb.ChangesetJSON, "error.json", changeset: changeset)
          end
        end
    end
  end

  # ========== DETALHES DA CORRIDA ==========
  def show(conn, %{"id" => id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        ride = Rides.get_ride!(id)
        
        cond do
          current_user.role == "admin" ->
            render(conn, "show.json", ride: ride)

          current_user.role == "user" and ride.user_id == current_user.id ->
            render(conn, "show.json", ride: ride)

          current_user.role == "driver" and ride.driver_id == current_user.id ->
            render(conn, "show.json", ride: ride)

          true ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "Forbidden"})
        end
    end
  end

  # ========== ACEITAR CORRIDA (DRIVER) ==========
  def accept(conn, %{"id" => ride_id, "vehicle_id" => vehicle_id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      driver ->
        if driver.role != "driver" do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Only drivers can accept rides"})
        else
          case Rides.accept_ride(ride_id, driver.id, vehicle_id) do
            {:ok, %{ride: ride}} ->
              render(conn, "show.json", ride: ride)

            {:error, {:invalid_state, state}} ->
              conn
              |> put_status(:conflict)
              |> json(%{error: "Ride not in SOLICITADA state", current_state: state})

            {:error, _} ->
              conn
              |> put_status(:conflict)
              |> json(%{error: "Ride already accepted or driver not available"})
          end
        end
    end
  end

  # ========== INICIAR CORRIDA (DRIVER) ==========
  def start(conn, %{"id" => ride_id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      driver ->
        if driver.role != "driver" do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Only drivers can start rides"})
        else
          case Rides.start_ride(ride_id, driver.id) do
            {:ok, %{ride: ride}} ->
              render(conn, "show.json", ride: ride)

            {:error, {:invalid_state, state}} ->
              conn
              |> put_status(:conflict)
              |> json(%{error: "Ride not in ACEITA state", current_state: state})

            {:error, :unauthorized} ->
              conn
              |> put_status(:forbidden)
              |> json(%{error: "You are not the assigned driver"})
          end
        end
    end
  end

  # ========== FINALIZAR CORRIDA (DRIVER) ==========
  def complete(conn, %{"id" => ride_id, "final_price" => final_price, "payment_method" => method}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      driver ->
        if driver.role != "driver" do
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Only drivers can complete rides"})
        else
          case Rides.complete_ride(ride_id, driver.id, %{"final_price" => final_price, "payment_method" => method}) do
            {:ok, %{ride: ride}} ->
              render(conn, "show.json", ride: ride)

            {:error, {:invalid_state, state}} ->
              conn
              |> put_status(:conflict)
              |> json(%{error: "Ride not in EM_ANDAMENTO state", current_state: state})

            {:error, :unauthorized} ->
              conn
              |> put_status(:forbidden)
              |> json(%{error: "You are not the assigned driver"})
          end
        end
    end
  end

  # ========== CANCELAR CORRIDA ==========
  def cancel(conn, %{"id" => ride_id, "reason" => reason}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      actor ->
        ride = Rides.get_ride!(ride_id)
        
        cond do
          actor.role == "admin" ->
            do_cancel(conn, ride_id, actor.id, "admin", reason)

          actor.role == "user" and ride.user_id == actor.id ->
            do_cancel(conn, ride_id, actor.id, "user", reason)

          actor.role == "driver" and ride.driver_id == actor.id ->
            do_cancel(conn, ride_id, actor.id, "driver", reason)

          true ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "You cannot cancel this ride"})
        end
    end
  end

  defp do_cancel(conn, ride_id, actor_id, actor_role, reason) do
    case Rides.cancel_ride(ride_id, actor_id, actor_role, reason) do
      {:ok, %{ride: ride}} ->
        render(conn, "show.json", ride: ride)

      {:error, :already_canceled} ->
        conn
        |> put_status(:conflict)
        |> json(%{error: "Ride already canceled"})

      {:error, _} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Could not cancel ride"})
    end
  end

  # ========== HISTÓRICO DE ESTADOS ==========
  def history(conn, %{"id" => ride_id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        ride = Rides.get_ride!(ride_id)
        
        if authorized?(current_user, ride) do
          events =
            from(e in RideFast.Rides.RideEvent, where: e.ride_id == ^ride_id)
            |> Repo.all()

          render(conn, "history.json", events: events)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # ========== TODAS AS CORRIDAS (ADMIN) ==========
  def all(conn, params) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        if current_user.role == "admin" do
          page = String.to_integer(params["page"] || "1")
          size = String.to_integer(params["size"] || "50")

          rides =
            Ride
            |> limit(^size)
            |> offset(^((page - 1) * size))
            |> Repo.all()

          total = Repo.aggregate(Ride, :count, :id)

          conn
          |> put_status(:ok)
          |> render("index.json", rides: rides, pagination: %{page: page, size: size, total: total})
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Admin access required"})
        end
    end
  end

  # ========== VIEWS (mantido igual) ==========
  def render("index.json", %{rides: rides, pagination: pagination}) do
    %{
      data: Enum.map(rides, &render_ride/1),
      pagination: pagination
    }
  end

  def render("show.json", %{ride: ride}) do
    render_ride(ride)
  end

  def render("history.json", %{events: events}) do
    %{
      events: Enum.map(events, fn e ->
        %{
          id: e.id,
          from_state: e.from_state,
          to_state: e.to_state,
          actor_id: e.actor_id,
          actor_role: e.actor_role,
          inserted_at: e.inserted_at
        }
      end)
    }
  end

  defp render_ride(ride) do
    %{
      id: ride.id,
      origin: %{lat: ride.origin_lat, lng: ride.origin_lng},
      destination: %{lat: ride.dest_lat, lng: ride.dest_lng},
      status: ride.status,
      requested_at: ride.requested_at,
      started_at: ride.started_at,
      ended_at: ride.ended_at,
      price_estimate: ride.price_estimate,
      final_price: ride.final_price,
      user: if(ride.user, do: %{id: ride.user.id, name: ride.user.name}),
      driver: if(ride.driver, do: %{id: ride.driver.id, name: ride.driver.name}),
      vehicle: if(ride.vehicle, do: %{id: ride.vehicle.id, plate: ride.vehicle.plate}),
      payment: if(ride.payment, do: %{id: ride.payment.id, status: ride.payment.status}),
      ratings: Enum.map(ride.ratings, &%{id: &1.id, score: &1.score, comment: &1.comment})
    }
  end

  defp authorized?(%{role: "admin"}, _), do: true
  defp authorized?(%{id: id, role: "user"}, %{user_id: user_id}), do: id == user_id
  defp authorized?(%{id: id, role: "driver"}, %{driver_id: driver_id}), do: id == driver_id
  defp authorized?(_, _), do: false
end