defmodule BatchProcessCoordination.ProcessMaintenance do
  @behaviour BatchProcessCoordination.ProcessMaintenanceBehaviour

  import Ecto.Query

  alias BatchProcessCoordination.ProcessBatchKeys
  alias BatchProcessCoordination.Repo

  def register_process(process_name, key_space \\ 9) do
    for n <- 0..key_space do
      attrs = %{
        process_name: process_name,
        key: n,
        last_completed_at: Timex.now() |> Timex.shift(days: -1)
      }

      %ProcessBatchKeys{}
      |> ProcessBatchKeys.changeset(attrs)
      |> Repo.insert()
    end
  end

  def unregister_process(process_name) do
    (from pm in ProcessBatchKeys, where: pm.process_name == ^process_name)
    |> Repo.delete_all()
  end
end
