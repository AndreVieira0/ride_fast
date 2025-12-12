defmodule RideFastWeb.RolePlug do
  import Plug.Conn

  def init(default), do: default

  def call(conn, role) do
    current_user = Guardian.Plug.current_resource(conn)

    cond do
      is_nil(current_user) ->
        conn |> deny()

      Map.get(current_user, :role) == role ->
        conn

      true ->
        conn |> deny()
    end
  end

  defp deny(conn) do
    conn
    |> send_resp(403, Jason.encode!(%{error: "forbidden"}))
    |> halt()
  end
end
