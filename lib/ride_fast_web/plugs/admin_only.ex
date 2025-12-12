# lib/ride_fast_web/plugs/admin_only.ex
defmodule RideFastWeb.Plugs.AdminOnly do
  import Plug.Conn
  import Phoenix.Controller  # ← ADICIONAR

  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = conn.assigns[:current_user]

    if current_user && current_user.role == "admin" do
      conn
    else
      conn
      |> put_status(403)
      |> json(%{error: "Forbidden: admin only"})
      |> halt()
    end
  end
end
