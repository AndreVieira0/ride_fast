defmodule RideFastWeb.UserController do
  use RideFastWeb, :controller

  import Ecto.Query
  alias RideFast.Repo
  alias RideFast.Accounts
  alias RideFast.Accounts.User

  action_fallback RideFastWeb.FallbackController

  # ========== ADMIN ONLY ==========
  def index(conn, params) do
    # Verifica se current_user existe e é admin
    case conn.assigns[:current_user] do
      %User{role: "admin"} = current_user ->
        page = String.to_integer(params["page"] || "1")
        size = String.to_integer(params["size"] || "20")
        search = params["q"]

        query =
          if search do
            from(u in User, where: ilike(u.name, ^"%#{search}%"))
          else
            User
          end

        users =
          query
          |> limit(^size)
          |> offset(^((page - 1) * size))
          |> Repo.all()

        total = Repo.aggregate(query, :count, :id)

        json(conn, %{
          data: users,
          pagination: %{
            page: page,
            size: size,
            total: total,
            pages: ceil(total / size)
          }
        })
        
      %User{} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Admin access required"})
        
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
    end
  end

  def create(conn, %{"user" => user_params}) do
    case conn.assigns[:current_user] do
      %User{role: "admin"} ->
        with {:ok, %User{} = user} <- Accounts.register_user(user_params) do
          conn
          |> put_status(:created)
          |> put_resp_header("location", ~p"/api/v1/users/#{user}")
          |> render(:show, user: user)
        end
        
      %User{} ->
        conn
        |> put_status(:forbidden)
        |> json(%{error: "Admin access required"})
        
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
    end
  end

  # ========== AUTHENTICATED ==========
  def me(conn, _params) do
    case conn.assigns[:current_user] do
      %User{} = user ->
        render(conn, :show, user: user)
        
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
    end
  end

  def show(conn, %{"id" => id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        user = Accounts.get_user!(id)
        
        if current_user.role == "admin" or current_user.id == user.id do
          render(conn, :show, user: user)
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        user = Accounts.get_user!(id)
        
        if current_user.role == "admin" or current_user.id == user.id do
          with {:ok, %User{} = updated_user} <- Accounts.update_user(user, user_params) do
            render(conn, :show, user: updated_user)
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  def delete(conn, %{"id" => id}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        user = Accounts.get_user!(id)
        
        if current_user.role == "admin" or current_user.id == user.id do
          with {:ok, %User{}} <- Accounts.delete_user(user) do
            send_resp(conn, :no_content, "")
          end
        else
          conn
          |> put_status(:forbidden)
          |> json(%{error: "Forbidden"})
        end
    end
  end

  # ========== VIEW ==========
  def render("show.json", %{user: user}) do
    %{
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      role: user.role,
      inserted_at: user.inserted_at,
      updated_at: user.updated_at
    }
  end
end