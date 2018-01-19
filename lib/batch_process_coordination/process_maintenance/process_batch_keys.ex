defmodule BatchProcessCoordination.ProcessBatchKeys do
  use Ecto.Schema
  import Ecto.Changeset

  schema "process_batch_keys" do
    field :process_name, :string
    field :key, :integer
    field :machine, :string
    field :started_at, :utc_datetime
    field :last_completed_at, :utc_datetime

    timestamps()
  end

  def changeset(%__MODULE__{} = process_batch_key, attrs) do
    process_batch_key
    |> cast(attrs, [:process_name, :key, :machine, :started_at, :last_completed_at])
    |> validate_required([:process_name, :key])
  end
end
