defmodule RideFastWeb.VehicleController do
  use RideFastWeb, :controller

  alias RideFast.Vehicles
  alias RideFastWeb.VehicleJSON
  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers/:driver_id/vehicles
  def index(conn, %{"driver_id" => driver_id}) do
    vehicles = Vehicles.list_driver_vehicles(driver_id)
    render(conn, :index, vehicles: vehicles)
  end

  # POST /api/v1/drivers/:driver_id/vehicles
  def create(conn, %{"driver_id" => driver_id} = params) do
    driver_id = String.to_integer(driver_id)

    # Aceita tanto "vehicle": {...} quanto params soltos
    vehicle_params =
      cond do
        Map.has_key?(params, "vehicle") ->
          Map.put(params["vehicle"], "driver_id", driver_id)

        true ->
          params
          |> Map.drop(["driver_id"])
          |> Map.put("driver_id", driver_id)
      end

    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})

      current_user ->
        if current_user.role == "admin" or current_user.id == driver_id do
          with {:ok, vehicle} <- Vehicles.create_vehicle(vehicle_params) do
            conn
            |> put_status(:created)
            |> render(:show, vehicle: vehicle)
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # PUT /api/v1/vehicles/:id
  def update(conn, %{"id" => id} = params) do
    vehicle = Vehicles.get_vehicle!(id)

    # Aceita tanto "vehicle": {...} quanto params soltos
    update_params =
      cond do
        Map.has_key?(params, "vehicle") ->
          params["vehicle"]

        true ->
          Map.drop(params, ["id"])
      end

    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})

      current_user ->
        if current_user.role == "admin" or current_user.id == vehicle.driver_id do
          with {:ok, vehicle} <- Vehicles.update_vehicle(vehicle, update_params) do
            render(conn, :show, vehicle: vehicle)
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # DELETE /api/v1/vehicles/:id
  def delete(conn, %{"id" => id}) do
    vehicle = Vehicles.get_vehicle!(id)

    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})

      current_user ->
        if current_user.role == "admin" or current_user.id == vehicle.driver_id do
          with {:ok, _} <- Vehicles.delete_vehicle(vehicle) do
            send_resp(conn, :no_content, "")
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end
end
