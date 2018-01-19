defmodule BatchProcessCoordination.Repo.Migrations.AddUniqueConstraintOnProcessName do
  use Ecto.Migration

  def change do
    create unique_index(:process_batch_keys, [:process_name, :key])
  end
end
