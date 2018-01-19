defmodule BatchProcessCoordination.Repo.Migrations.CreateProcessModuliTable do
  
  use Ecto.Migration

  
  
  def change do


    create table(:process_moduli) do
      add :process_name,       :string
      add :remainder,          :integer
      add :machine,            :string
      add :started_at,         :utc_datetime
      add :last_completed_at,  :utc_datetime

      timestamps()
    end
  end

end
