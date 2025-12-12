defmodule RideFastWeb.Plugs.CurrentUser do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    resource = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, resource)
  end
end
