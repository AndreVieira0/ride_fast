defmodule RideFastWeb.AuthPipeline do
  @moduledoc """
  Pipeline para verificar token JWT e carregar current_user/current_driver.
  """
  use Guardian.Plug.Pipeline,
    otp_app: :ride_fast,
    module: RideFast.Token.Guardian,
    error_handler: RideFastWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, scheme: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource

  # ADICIONE ESTE PLUG PARA COLOCAR O USUÁRIO NO conn.assigns
  plug :put_current_user

  defp put_current_user(conn, _) do
    user = Guardian.Plug.current_resource(conn)
    assign(conn, :current_user, user)
  end
end
