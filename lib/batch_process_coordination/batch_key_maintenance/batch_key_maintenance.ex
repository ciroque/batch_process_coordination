defmodule BatchProcessCoordination.BatchKeyMaintenance do
  @behaviour BatchProcessCoordination.BatchKeyMaintenanceBehaviour

  import Ecto.Query

  alias BatchProcessCoordination.{ProcessBatchKeys, Repo}

  require Logger

  def request_batch_key(process_name, machine) do
    update = [set: [machine: machine, started_at: Timex.now()]]
    query =
    (
      from pm in ProcessBatchKeys,
      join: batch_key in subquery(claim_next_batch_key_for(process_name)),
        on: batch_key.id == pm.id
    )

    case query |> Repo.update_all(update, [returning: true]) do
      {0, []} ->
        Logger.info("#{__MODULE__}::request_batch_key All keys in use")
        {:no_keys_free}
      {1, [%{key: key, machine: machine, process_name: process_name, started_at: started_at}]} ->
        result = {:ok, %{key: key, machine: machine, process_name: process_name, started_at: started_at}}
        Logger.info("#{__MODULE__}::request_batch_key Result: #{inspect(result)}")
        result
      r ->
        log_key = Ecto.UUID.generate()
        Logger.error("#{__MODULE__}::request_batch_key [log_key: #{log_key}] Unexpected result from update query: #{inspect(r)}")
        {:error, "An error occured. Please review the logs for details. Log key: #{log_key}"}
    end
  end

  def release_batch_key(%{key: key, machine: machine, process_name: process_name, started_at: started_at}) do
    query = (
      from pm in ProcessBatchKeys,
      where: 1 == 1
        and pm.process_name == ^process_name
        and pm.key == ^key
        and pm.machine == ^machine
        and not is_nil(pm.started_at)
    )
    update = [set: [machine: nil, started_at: nil, last_completed_at: Timex.now()]]
    case query |> Repo.update_all(update, [returning: true]) do
      {0, []} ->
        Logger.info("#{__MODULE__}::release_batch_key Attempt to release unknown key; process_name: #{process_name}, machine: #{machine}, key: #{key}")
        {:not_found}
      {1, [%{last_completed_at: last_completed_at}]} ->
        {:ok, %{
          key: key,
          machine: machine,
          process_name: process_name,
          started_at: started_at,
          completed_at: last_completed_at
        }}
      r ->
        log_key = Ecto.UUID.generate()
        Logger.error("#{__MODULE__}::release_batch_key [log_key: #{log_key}] Unexpected result from update query: #{inspect(r)}")
        {:error, "An error occured. Please review the logs for details. Log key: #{log_key}"}
    end
  end

  def list_batch_keys(process_name) do
    (from pm in ProcessBatchKeys, where: pm.process_name == ^process_name, select: pm) |> Repo.all
  end

  defp batch_keys_for(process_name) do
    (
      from pm in ProcessBatchKeys,
      where: 1 == 1
        and is_nil(pm.started_at)
        and is_nil(pm.machine)
        and pm.process_name == ^process_name,
      select: %{
        key: pm.key,
        row_number: fragment("row_number() over (order by last_completed_at)")
      }
    )
  end

  defp first_batch_key_for(process_name) do
    (
      from r in subquery(batch_keys_for(process_name)),
      where: r.row_number < 2,
      select: r.key
    )
  end

  defp claim_next_batch_key_for(process_name) do
    (
      from pm in ProcessBatchKeys,
      join: batch_keys in subquery(first_batch_key_for(process_name)),
        on: batch_keys.key == pm.key,
      where: pm.process_name == ^process_name
    )
  end
end
