defmodule BatchProcessCoordination.ProcessMaintenance do
  @behaviour BatchProcessCoordination.ProcessMaintenanceBehaviour

  import Ecto.Query

  alias BatchProcessCoordination.ProcessBatchKeys
  alias BatchProcessCoordination.Repo

  def register_process(process_name, key_space \\ 10) do
    batch_keys = for n <- 0..key_space - 1 do
      attrs = %{
        process_name: process_name,
        key: n,
        last_completed_at: Timex.now() |> Timex.shift(days: -1)
      }

      %ProcessBatchKeys{}
      |> ProcessBatchKeys.changeset(attrs)
      |> Repo.insert()
    end

    {:ok, %{process_name: process_name, key_space_size: length(batch_keys)}}
  end

  def unregister_process(process_name) do
    {count, _} = (from pm in ProcessBatchKeys, where: pm.process_name == ^process_name)
    |> Repo.delete_all()

    {:ok, %{process_name: process_name, key_space_size: count}}
  end

  def list_processes() do
    processes = (
      from pm in ProcessBatchKeys,
      group_by: pm.process_name,
      select: %{
        process_name: pm.process_name,
        key_space_size: count(pm.id)
      }
    ) |> Repo.all
    {:ok, processes}
  end
end
