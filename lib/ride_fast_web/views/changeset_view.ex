defmodule RideFastWeb.ChangesetView do
  alias Ecto.Changeset

  def render("error.json", %{changeset: %Changeset{} = changeset}) do
    %{errors: translate_errors(changeset)}
  end

  def translate_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
