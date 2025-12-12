defmodule RideFastWeb.DriverJSON do
  alias RideFast.Accounts.Driver
  alias RideFastWeb.VehicleJSON
  alias RideFastWeb.LanguageJSON
  alias RideFastWeb.DriverProfileJSON

  # LISTA DE DRIVERS
  def index(%{drivers: drivers}) do
    list = for driver <- drivers, do: data(driver)
    %{data: list}
  end

  # MOSTRAR UM DRIVER
  def show(%{driver: driver}) do
    %{data: data(driver)}
  end

  # COMO SERIALIZAR UM DRIVER
  defp data(%Driver{} = driver) do
    profile =
      if Ecto.assoc_loaded?(driver.profile) do
        DriverProfileJSON.data(driver.profile)
      else
        nil
      end

    vehicles =
      if Ecto.assoc_loaded?(driver.vehicles) do
        VehicleJSON.index(%{vehicles: driver.vehicles}).data
      else
        []
      end

    languages =
      if Ecto.assoc_loaded?(driver.languages) do
        LanguageJSON.index(%{languages: driver.languages}).data
      else
        []
      end

    %{
      id: driver.id,
      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      status: driver.status,
      inserted_at: driver.inserted_at,
      updated_at: driver.updated_at,
      profile: profile,
      vehicles: vehicles,
      languages: languages
    }
  end
end
