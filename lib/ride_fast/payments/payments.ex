defmodule RideFast.Payments do
  @moduledoc """
  Contexto responsável por pagamentos associados à ride.
  """

  import Ecto.Query  # ← ADICIONAR
  alias RideFast.Repo
  alias RideFast.Payments.Payment

  # ==========================
  # LISTAR PAGAMENTOS (ADMIN)
  # ==========================

  def list_payments do
    Repo.all(Payment)
  end

  # ==========================
  # PEGAR PAGAMENTO POR RIDE
  # ==========================

  def get_payment_by_ride(ride_id) do
    from(p in Payment, where: p.ride_id == ^ride_id)
    |> Repo.one()
  end

  # ==========================
  # CRIAR PAGAMENTO (caso queira manual)
  # ==========================

  def create_payment(attrs) do
    %Payment{}
    |> Payment.changeset(attrs)
    |> Repo.insert()
  end
end
