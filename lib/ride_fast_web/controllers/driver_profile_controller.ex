defmodule RideFastWeb.DriverProfileController do
  use RideFastWeb, :controller
  alias RideFast.Accounts
  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers/:driver_id/profile
  def show(conn, %{"driver_id" => driver_id}) do
    profile = Accounts.get_driver_profile(driver_id)

    if profile do
      render(conn, :show, profile: profile)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Profile not found"})
    end
  end

  # POST /api/v1/drivers/:driver_id/profile
  def create(conn, %{"driver_id" => driver_id} = params) do
    profile_params =
      cond do
        Map.has_key?(params, "profile") -> params["profile"]
        true -> params
      end

    authorize_and_run(conn, driver_id, fn ->
      params = Map.put(profile_params, "driver_id", driver_id)

      with {:ok, profile} <- Accounts.create_driver_profile(params) do
        conn
        |> put_status(:created)
        |> render(:show, profile: profile)
      end
    end)
  end

  # PUT /api/v1/drivers/:driver_id/profile
  def update(conn, %{"driver_id" => driver_id} = params) do
    profile_params =
      cond do
        Map.has_key?(params, "profile") -> params["profile"]
        true -> params
      end

    authorize_and_run(conn, driver_id, fn ->
      profile = Accounts.get_driver_profile(driver_id)

      if profile do
        with {:ok, profile} <- Accounts.update_driver_profile(profile, profile_params) do
          render(conn, :show, profile: profile)
        end
      else
        conn
        |> put_status(:not_found)
        |> json(%{error: "Profile not found"})
      end
    end)
  end

  # --------- PRIVATE ---------

  defp authorize_and_run(conn, driver_id, fun) do
    current_user = conn.assigns[:current_user]

    cond do
      current_user == nil ->
        conn |> put_status(:unauthorized) |> json(%{error: "Authentication required"})

      current_user.role == "admin" ->
        fun.()

      current_user.id == String.to_integer(driver_id) ->
        fun.()

      true ->
        conn |> put_status(:forbidden) |> json(%{error: "Forbidden"})
    end
  end
end
