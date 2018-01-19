defmodule BatchProcessCoordination.Repo.Migrations.CreateIndexOnName do
  use Ecto.Migration

  def change do
    create index(:process_batch_keys, [:process_name])
  end
end
