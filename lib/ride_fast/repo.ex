defmodule RideFast.Repo do
  use Ecto.Repo,
    otp_app: :ride_fast,
    adapter: Ecto.Adapters.MyXQL
end
