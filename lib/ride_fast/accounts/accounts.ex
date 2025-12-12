defmodule RideFast.Accounts do
  @moduledoc """
  Contexto responsável por gerenciar Users e Drivers.
  """

  alias RideFast.Repo
  alias RideFast.Accounts.{User, Driver, DriverProfile}

  import Ecto.Query  # ← ADICIONAR ESTA LINHA

  # ========== USERS ==========

  def list_users(opts \\ []) do
    User
    |> maybe_paginate(opts)
    |> Repo.all()
  end

  def get_user!(id), do: Repo.get!(User, id)

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  # ========== DRIVERS ==========

  def list_drivers(filters \\ %{}) do
    Driver
    |> apply_driver_filters(filters)
    |> Repo.all()
  end

  def get_driver!(id), do: Repo.get!(Driver, id)

  def register_driver(attrs) do
    %Driver{}
    |> Driver.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_driver(%Driver{} = driver, attrs) do
    driver
    |> Driver.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_driver(%Driver{} = driver) do
    Repo.delete(driver)
  end

  # ========== AUTH ==========

  def authenticate(email, password) do
    case Repo.get_by(User, email: email) do
      %User{password_hash: hash} = user ->
        if Bcrypt.verify_pass(password, hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end

      nil ->
        case Repo.get_by(Driver, email: email) do
          %Driver{password_hash: hash} = driver ->
            if Bcrypt.verify_pass(password, hash) do
              {:ok, driver}
            else
              {:error, :invalid_credentials}
            end

          nil ->
            {:error, :invalid_credentials}
        end
    end
  end

  # ========== DRIVER PROFILES ==========

  def get_driver_profile(driver_id) do
    Repo.get_by(DriverProfile, driver_id: driver_id)
  end

  def create_driver_profile(attrs) do
    %DriverProfile{}
    |> DriverProfile.changeset(attrs)
    |> Repo.insert()
  end

  def update_driver_profile(%DriverProfile{} = profile, attrs) do
    profile
    |> DriverProfile.changeset(attrs)
    |> Repo.update()
  end

  # ========== PRIVATE ==========

  defp maybe_paginate(query, %{page: page, size: size}) do
    from(q in query, limit: ^size, offset: ^((page - 1) * size))
  end

  defp maybe_paginate(query, _), do: query

  defp apply_driver_filters(query, %{status: status}) do
    from(q in query, where: q.status == ^status)
  end

  defp apply_driver_filters(query, _), do: query
end
