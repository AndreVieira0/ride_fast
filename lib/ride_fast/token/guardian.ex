defmodule RideFast.Token.Guardian do
  use Guardian, otp_app: :ride_fast

  alias RideFast.Accounts

  def subject_for_token(resource, _claims) do
    sub = to_string(resource.id)
    {:ok, sub}
  end

  def resource_from_claims(%{"sub" => id}) do
    # Tenta achar User, depois Driver
    case Accounts.get_user!(id) do
      %{} = user -> {:ok, user}
      _ ->
        case Accounts.get_driver!(id) do
          %{} = driver -> {:ok, driver}
          _ -> {:error, :not_found}
        end
    end
  rescue
    Ecto.NoResultsError -> {:error, :not_found}
  end
end
