defmodule BatchProcessCoordination.ProcessModuli do
  use Ecto.Schema
  import Ecto.Changeset

  schema "process_moduli" do
    field :process_name, :string
    field :remainder, :integer
    field :machine, :string
    field :started_at, :utc_datetime
    field :last_completed_at, :utc_datetime

    timestamps()
  end

  def changeset(%__MODULE__{} = process_moduli, attrs) do
    process_moduli
    |> cast(attrs, [:process_name, :remainder, :machine, :started_at, :last_completed_at])
    |> validate_required([:process_name, :remainder])
  end
end
