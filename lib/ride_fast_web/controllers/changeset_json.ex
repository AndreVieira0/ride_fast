defmodule RideFastWeb.ChangesetJSON do
  @doc """
  Renders changeset errors.
  """
  def render_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  def error(%{changeset: changeset}) do
    %{errors: render_errors(changeset)}
  end
end
