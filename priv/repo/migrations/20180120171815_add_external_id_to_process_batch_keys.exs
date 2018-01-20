defmodule BatchProcessCoordination.Repo.Migrations.AddExternalIdToProcessBatchKeys do
  use Ecto.Migration

  def change do
    alter table(:process_batch_keys) do
      add :external_id, :string
    end
  end
end
