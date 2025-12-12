defmodule RideFast.Payments.Payment do
  use Ecto.Schema
  import Ecto.Changeset

  @valid_methods ~w(CARD CASH PIX)
  @valid_statuses ~w(PENDING PAID FAILED)

  schema "payments" do
    field :amount, :float
    field :method, :string
    field :status, :string, default: "PENDING"

    belongs_to :ride, RideFast.Rides.Ride

    timestamps()
  end

  def changeset(payment, attrs) do
    payment
    |> cast(attrs, [:amount, :method, :status, :ride_id])
    |> validate_required([:amount, :method, :status, :ride_id])
    |> validate_inclusion(:method, @valid_methods)
    |> validate_inclusion(:status, @valid_statuses)
    |> unique_constraint(:ride_id)
  end
end
