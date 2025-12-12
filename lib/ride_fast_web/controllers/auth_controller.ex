defmodule RideFastWeb.AuthController do
  use RideFastWeb, :controller

  alias RideFast.Accounts
  alias RideFast.Token.Guardian

  # ========== REGISTRO UNIFICADO (com role) ==========
  def register(conn, %{"role" => "user",} = params) do
    with {:ok, user} <- Accounts.register_user(params) do
      send_token(conn, user)
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors: RideFastWeb.ChangesetJSON.render_errors(changeset)})
    end
  end

  def register(conn, %{"role" => "driver"} = params) do
    with {:ok, driver} <- Accounts.register_driver(params) do
      send_token(conn, driver)
    else
      {:error, changeset} ->
        conn
        |> put_status(400)
        |> json(%{errors: RideFastWeb.ChangesetJSON.render_errors(changeset)})
    end
  end

  def register(conn, _) do
    conn
    |> put_status(400)
    |> json(%{error: "Parâmetro 'role' obrigatório: 'user' ou 'driver'"})
  end

  # ========== LOGIN UNIFICADO ==========
  def login(conn, %{"email" => email, "password" => password}) do
    case Accounts.authenticate(email, password) do
      {:ok, user_or_driver} ->
        send_token(conn, user_or_driver)

      {:error, :invalid_credentials} ->
        conn
        |> put_status(401)
        |> json(%{error: "Email ou senha inválidos"})
    end
  end

  # ========== LOGOUT ==========
  def logout(conn, _params) do
    token = Guardian.Plug.current_token(conn)
    Guardian.revoke(token)

    json(conn, %{message: "Logged out successfully"})
  end

  # ========== PRIVATE ==========
  defp send_token(conn, resource) do
    {:ok, token, _claims} = Guardian.encode_and_sign(resource)

    conn
    |> put_status(200)
    |> json(%{
      token: token,
      token_type: "Bearer",
      user: %{
        id: resource.id,
        name: resource.name,
        email: resource.email,
        role: if(Map.has_key?(resource, :role), do: resource.role, else: "driver")
      }
    })
  end
end
