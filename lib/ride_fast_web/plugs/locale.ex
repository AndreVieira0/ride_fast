defmodule RideFastWeb.Plugs.Locale do
  import Plug.Conn

  def init(default), do: default

  def call(conn, _default) do
    case conn |> get_req_header("accept-language") |> List.first() do
      nil -> conn
      lang -> assign(conn, :locale, String.slice(lang, 0, 2))
    end
  end
end
