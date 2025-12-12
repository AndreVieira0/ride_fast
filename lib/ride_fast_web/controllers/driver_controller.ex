defmodule RideFastWeb.DriverController do
  use RideFastWeb, :controller
  alias RideFast.Accounts
  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/drivers (público, com filtros)
  def index(conn, params) do
    filters = %{}
    |> Map.put(:status, params["status"])
    |> Map.put(:language, params["language"])
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()

    drivers = Accounts.list_drivers(filters)

    json(conn, %{
      data: Enum.map(drivers, fn driver ->
        %{
          id: driver.id,
          name: driver.name,
          email: driver.email,
          phone: driver.phone,
          status: driver.status,
          inserted_at: driver.inserted_at
        }
      end)
    })
  end

  # GET /api/v1/drivers/:id (público)
  def show(conn, %{"id" => id}) do
    driver = Accounts.get_driver!(id)
    render(conn, :show, driver: driver)
  end

  # POST /api/v1/drivers (admin only)
  def create(conn, %{"driver" => driver_params}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        if current_user.role == "admin" do
          with {:ok, driver} <- Accounts.register_driver(driver_params) do
            conn
            |> put_status(:created)
            |> render(:show, driver: driver)
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Admin access required"})
        end
    end
  end

  # PUT /api/v1/drivers/:id (driver owner ou admin)
  def update(conn, %{"id" => id, "driver" => driver_params}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        driver = Accounts.get_driver!(id)
        
        if current_user.role == "admin" or current_user.id == driver.id do
          with {:ok, driver} <- Accounts.update_driver(driver, driver_params) do
            render(conn, :show, driver: driver)
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # DELETE /api/v1/drivers/:id (admin only)
  def delete(conn, %{"id" => id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        if current_user.role == "admin" do
          driver = Accounts.get_driver!(id)
          with {:ok, _} <- Accounts.delete_driver(driver) do
            send_resp(conn, :no_content, "")
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Admin access required"})
        end
    end
  end

  # VIEWS (mantido igual)
  def render("index.json", %{drivers: drivers}) do
    %{data: Enum.map(drivers, &render_driver/1)}
  end

  def render("show.json", %{driver: driver}) do
    render_driver(driver)
  end

  defp render_driver(driver) do
    %{
      id: driver.id,
      name: driver.name,
      email: driver.email,
      phone: driver.phone,
      status: driver.status,
      inserted_at: driver.inserted_at
    }
  end
end