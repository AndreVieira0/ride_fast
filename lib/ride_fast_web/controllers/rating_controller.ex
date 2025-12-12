defmodule RideFastWeb.RatingController do
  use RideFastWeb, :controller
  alias RideFast.Ratings
  alias RideFast.Rides
  action_fallback RideFastWeb.FallbackController

  # POST /api/v1/rides/:ride_id/ratings
  def create(conn, %{"ride_id" => ride_id, "rating" => rating_params}) do
    case conn.assigns[:current_user] do
      nil ->
        conn
        |> put_status(:unauthorized)
        |> json(%{error: "Authentication required"})
        
      current_user ->
        ride = Rides.get_ride!(ride_id)
        
        # Validações: ride FINALIZADA, usuário é participante
        cond do
          ride.status != "FINALIZADA" ->
            conn
            |> put_status(:conflict)
            |> json(%{error: "Ride not finished"})

          current_user.id not in [ride.user_id, ride.driver_id] ->
            conn
            |> put_status(:forbidden)
            |> json(%{error: "You are not a participant"})

          true ->
            params =
              rating_params
              |> Map.put("ride_id", ride_id)
              |> Map.put("from_user_id", current_user.id)
              |> Map.put("to_driver_id", ride.driver_id)

            with {:ok, rating} <- Ratings.create_rating(params) do
              conn
              |> put_status(:created)
              |> render(:show, rating: rating)
            end
        end
    end
  end

  # GET /api/v1/rides/:ride_id/ratings (público)
  def ride_ratings(conn, %{"ride_id" => ride_id}) do
    ratings = Ratings.list_ride_ratings(ride_id)
    render(conn, :index, ratings: ratings)
  end

  # GET /api/v1/drivers/:driver_id/ratings (público)
  def driver_ratings(conn, %{"driver_id" => driver_id}) do
    ratings = Ratings.list_driver_ratings(driver_id)
    render(conn, :index, ratings: ratings)
  end

  # VIEWS (mantido igual)
  def render("index.json", %{ratings: ratings}) do
    %{data: Enum.map(ratings, &render_rating/1)}
  end

  def render("show.json", %{rating: rating}) do
    render_rating(rating)
  end

  defp render_rating(rating) do
    %{
      id: rating.id,
      ride_id: rating.ride_id,
      from_user_id: rating.from_user_id,
      to_driver_id: rating.to_driver_id,
      score: rating.score,
      comment: rating.comment,
      inserted_at: rating.inserted_at
    }
  end
end