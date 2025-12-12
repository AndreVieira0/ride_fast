defmodule RideFastWeb.PaymentController do
  use RideFastWeb, :controller
  alias RideFast.Payments
  action_fallback RideFastWeb.FallbackController

  # GET /api/v1/payments (admin only)
  def index(conn, _params) do
    payments = Payments.list_payments()
    render(conn, :index, payments: payments)
  end

  # GET /api/v1/payments/ride/:ride_id
  def by_ride(conn, %{"ride_id" => ride_id}) do
    payment = Payments.get_payment_by_ride(ride_id)

    if payment do
      render(conn, :show, payment: payment)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "Payment not found"})
    end
  end

  # VIEWS
  def render("index.json", %{payments: payments}) do
    %{data: Enum.map(payments, &render_payment/1)}
  end

  def render("show.json", %{payment: payment}) do
    render_payment(payment)
  end

  defp render_payment(payment) do
    %{
      id: payment.id,
      ride_id: payment.ride_id,
      amount: payment.amount,
      method: payment.method,
      status: payment.status,
      inserted_at: payment.inserted_at
    }
  end
end

