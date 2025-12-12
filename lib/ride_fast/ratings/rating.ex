defmodule RideFast.Ratings.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :score, :integer
    field :comment, :string

    belongs_to :ride, RideFast.Rides.Ride
    belongs_to :from_user, RideFast.Accounts.User
    belongs_to :to_driver, RideFast.Accounts.Driver

    timestamps()
  end

  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:score, :comment, :ride_id, :from_user_id, :to_driver_id])
    |> validate_required([:score, :ride_id, :from_user_id, :to_driver_id])
    |> validate_number(:score, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> unique_constraint([:ride_id, :from_user_id, :to_driver_id],
         name: :unique_rating_per_ride_user_driver)
  end
end
