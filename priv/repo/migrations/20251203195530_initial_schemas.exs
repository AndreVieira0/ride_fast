defmodule RideFast.Repo.Migrations.InitialSchema do
  use Ecto.Migration

  def change do
    # ===================== USERS =====================
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :password_hash, :string, null: false
      add :role, :string, default: "user"
      timestamps()
    end

    create unique_index(:users, [:email])

    # ===================== DRIVERS =====================
    create table(:drivers) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :phone, :string
      add :password_hash, :string, null: false
      add :status, :string, default: "active"
      timestamps()
    end

    create unique_index(:drivers, [:email])

    # ===================== DRIVER PROFILES =====================
    create table(:driver_profiles) do
      add :driver_id, references(:drivers, on_delete: :delete_all), null: false
      add :license_number, :string, null: false
      add :license_expiry, :date, null: false
      add :background_check_ok, :boolean, default: false
      timestamps()
    end

    create unique_index(:driver_profiles, [:driver_id])
    create unique_index(:driver_profiles, [:license_number])

    # ===================== VEHICLES =====================
    create table(:vehicles) do
      add :driver_id, references(:drivers, on_delete: :delete_all), null: false
      add :plate, :string, null: false
      add :model, :string, null: false
      add :color, :string, null: false
      add :seats, :integer, default: 4
      add :active, :boolean, default: true
      timestamps()
    end

    create unique_index(:vehicles, [:plate])
    create index(:vehicles, [:driver_id])

    # ===================== LANGUAGES =====================
    create table(:languages) do
      add :code, :string, null: false
      add :name, :string, null: false
      timestamps()
    end

    create unique_index(:languages, [:code])

    # ===================== DRIVER ↔ LANGUAGE =====================
    create table(:driver_languages) do
      add :driver_id, references(:drivers, on_delete: :delete_all), null: false
      add :language_id, references(:languages, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:driver_languages, [:driver_id, :language_id])

    # ===================== RIDES =====================
    create table(:rides) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :driver_id, references(:drivers, on_delete: :nilify_all)
      add :vehicle_id, references(:vehicles, on_delete: :nilify_all)

      add :origin_lat, :float, null: false
      add :origin_lng, :float, null: false
      add :dest_lat, :float, null: false
      add :dest_lng, :float, null: false

      add :status, :string, null: false, default: "SOLICITADA"
      add :requested_at, :utc_datetime
      add :started_at, :utc_datetime
      add :ended_at, :utc_datetime

      add :price_estimate, :float
      add :final_price, :float

      timestamps()
    end

    create index(:rides, [:user_id])
    create index(:rides, [:driver_id])
    create index(:rides, [:status])

    # ===================== PAYMENTS =====================
    create table(:payments) do
      add :ride_id, references(:rides, on_delete: :delete_all), null: false
      add :amount, :float, null: false
      add :method, :string, null: false
      add :status, :string, null: false, default: "PENDING"
      timestamps()
    end

    create unique_index(:payments, [:ride_id])

    # ===================== RATINGS =====================
    create table(:ratings) do
      add :ride_id, references(:rides, on_delete: :delete_all), null: false
      add :from_user_id, references(:users, on_delete: :delete_all), null: false
      add :to_driver_id, references(:drivers, on_delete: :delete_all), null: false

      add :score, :integer, null: false
      add :comment, :string

      timestamps()
    end

    create unique_index(:ratings, [:ride_id, :from_user_id, :to_driver_id],
      name: :unique_rating_per_ride_user_driver
    )

    # ===================== RIDE EVENTS =====================
    create table(:ride_events) do
      add :ride_id, references(:rides, on_delete: :delete_all), null: false
      add :from_state, :string, null: false
      add :to_state, :string, null: false
      add :actor_id, :integer, null: false
      add :actor_role, :string, null: false
      timestamps()
    end

    create index(:ride_events, [:ride_id])
  end
end
