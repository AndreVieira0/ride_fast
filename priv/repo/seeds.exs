# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RideFast.Repo.insert!(%RideFast.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias RideFast.Repo
alias RideFast.Accounts.User
alias Bcrypt

admin_email = "admin@ridefast.com"

case Repo.get_by(User, email: admin_email) do
  nil ->
    Repo.insert! %User{
      name: "Administrador",
      email: admin_email,
      phone: "85900000000",
      role: "admin",
      password_hash: Bcrypt.hash_pwd_salt("123456")
    }

    IO.puts(">>> Admin criado com sucesso! Email: #{admin_email}")

  _ ->
    IO.puts(">>> Admin já existe. Nenhum novo usuário criado.")
end
