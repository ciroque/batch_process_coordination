defmodule BatchProcessCoordination.Repo.Migrations.CreateProcessBatchKeysTable do
  use Ecto.Migration

  def change do
    create table(:process_batch_keys) do
      add :process_name,       :string
      add :key,                :integer
      add :machine,            :string
      add :started_at,         :utc_datetime
      add :last_completed_at,  :utc_datetime

      timestamps()
    end
  end
end
