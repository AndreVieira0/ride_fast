defmodule RideFastWeb.FallbackController do
  use RideFastWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(json: RideFastWeb.ChangesetJSON)
    |> render(:error, changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(json: RideFastWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, :unauthorized}) do
    conn
    |> put_status(:forbidden)
    |> json(%{error: "You are not authorized to perform this action"})
  end

  def call(conn, {:error, {:invalid_state, state}}) do
    conn
    |> put_status(:conflict)
    |> json(%{error: "Invalid state transition", current_state: state})
  end
end
