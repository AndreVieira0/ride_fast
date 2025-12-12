defmodule RideFast.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone, :string
    field :role, :string, default: "user"
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :rides, RideFast.Rides.Ride, foreign_key: :user_id
    has_many :ratings_given, RideFast.Ratings.Rating, foreign_key: :from_user_id
    has_many :ratings_received, RideFast.Ratings.Rating, foreign_key: :to_user_id

    timestamps()
  end

  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone, :password, :role])
    |> validate_required([:name, :email, :phone, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> put_password_hash()
  end

  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :phone])
    |> validate_required([:name, :email, :phone])
    |> unique_constraint(:email)
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password_hash: Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
