defmodule RideFastWeb.UserJSON do
  alias RideFast.Accounts.User

  # retorno para GET /users/:id
  def show(%{user: %User{} = user}) do
    %{
      data: %{
        id: user.id,
        name: user.name,
        email: user.email
      }
    }
  end

  # retorno para GET /users
  def index(%{users: users}) do
    %{data: Enum.map(users, &user_data/1)}
  end

  defp user_data(%User{} = user) do
    %{
      id: user.id,
      name: user.name,
      email: user.email
    }
  end
end
