defmodule RideFast.Ratings do
  import Ecto.Query
  alias RideFast.Repo
  alias RideFast.Ratings.Rating

  def list_ride_ratings(ride_id) do
    from(r in Rating, where: r.ride_id == ^ride_id)
    |> Repo.all()
  end

  def list_driver_ratings(driver_id) do
    from(r in Rating, where: r.to_driver_id == ^driver_id)
    |> Repo.all()
  end

  def create_rating(attrs) do
    %Rating{}
    |> Rating.changeset(attrs)
    |> Repo.insert()
  end
end

