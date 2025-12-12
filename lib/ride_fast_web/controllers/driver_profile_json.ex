defmodule RideFastWeb.DriverProfileJSON do
  alias RideFast.Accounts.DriverProfile

  # usado pelo show
  def show(%{profile: profile}) do
    %{data: data(profile)}
  end

  # usado pelo index (se precisar futuramente)
  def index(%{profiles: profiles}) do
    %{data: Enum.map(profiles, &data/1)}
  end

  # serialização final
  def data(%DriverProfile{} = profile) do
    %{
      id: profile.id,
      driver_id: profile.driver_id,
      license_number: profile.license_number,
      license_expiry: profile.license_expiry,
      background_check_ok: profile.background_check_ok,
      inserted_at: profile.inserted_at,
      updated_at: profile.updated_at
    }
  end
end
