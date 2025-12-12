defmodule RideFastWeb.VehicleJSON do
  alias RideFast.Vehicles.Vehicle

  # Lista de veículos
  def index(%{vehicles: vehicles}) do
    %{data: Enum.map(vehicles, &data/1)}
  end

  # Um único veículo
  def show(%{vehicle: vehicle}) do
    %{data: data(vehicle)}
  end

  # Estrutura do JSON final
  def data(%Vehicle{} = vehicle) do
    %{
      id: vehicle.id,
      plate: vehicle.plate,
      model: vehicle.model,
      color: vehicle.color,
      seats: vehicle.seats,
      active: vehicle.active,
      driver_id: vehicle.driver_id,
      inserted_at: vehicle.inserted_at,
      updated_at: vehicle.updated_at
    }
  end
end
