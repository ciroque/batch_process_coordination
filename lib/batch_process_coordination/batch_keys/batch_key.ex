defmodule BatchProcessCoordination.BatchKey do
  @behaviour BatchProcessCoordination.BatchKeyBehaviour

  import BatchProcessCoordination.Helpers
  import Ecto.Query

  alias BatchProcessCoordination.{BatchKeyInfo, ProcessBatchKeys, Repo}
  alias Ecto.UUID

  require Logger

  def list_batch_keys(process_name) do
    batch_keys = (from pm in ProcessBatchKeys, where: pm.process_name == ^process_name, select: pm)
    |> Repo.all
    |> Enum.map(fn batch_key ->
      %BatchKeyInfo{
        last_completed_at: batch_key.last_completed_at,
        external_id: batch_key.external_id,
        key: batch_key.key,
        machine: batch_key.machine,
        process_name: batch_key.process_name,
        started_at: batch_key.started_at,
      }
    end)

    {:ok, batch_keys}
  end

  def release_batch_key(%{key: key, machine: machine, process_name: process_name}) do
    query = (
      from pm in ProcessBatchKeys,
           where: 1 == 1
                  and pm.process_name == ^process_name
                  and pm.key == ^key
                  and pm.machine == ^machine
           and not is_nil(pm.started_at)
      )
    update = release_batch_key_update_clause()
    release_batch_key_impl(query, update)
  end

  def release_batch_key(external_id) when is_binary(external_id) do
    query = (from pm in ProcessBatchKeys, where: pm.external_id == ^external_id and not is_nil(pm.started_at))
    update = release_batch_key_update_clause()
    release_batch_key_impl(query, update)
  end

  def request_batch_key(process_name, machine) do
    cond do
      process_name_exists(process_name) ->
        claim_batch_key_for(process_name, machine)
      true ->
        {:error, :not_found}
    end
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

  defp claim_batch_key_for(process_name, machine) do
    update = [set: [machine: machine, started_at: Timex.now(), external_id: UUID.generate()]]
    query =
      (
        from pm in ProcessBatchKeys,
             join: batch_key in subquery(claim_next_batch_key_for(process_name)),
             on: batch_key.id == pm.id
        )

    case query |> Repo.update_all(update, [returning: true]) do
      {0, []} ->
        Logger.info("#{__MODULE__}::request_batch_key All keys in use")
        {:error, :no_keys_free}
#        {:error, "All keys for process '#{process_name}' have been reserved."}
      {1, [%ProcessBatchKeys{key: key, last_completed_at: last_completed_at, machine: machine, process_name: process_name, started_at: started_at, external_id: external_id}]} ->
        result = {:ok, %BatchKeyInfo{key: key, last_completed_at: last_completed_at, machine: machine, process_name: process_name, started_at: started_at, external_id: external_id}}
        Logger.info("#{__MODULE__}::request_batch_key Result: #{inspect(result)}")
        result
      r ->
        log_key = UUID.generate()
        Logger.error("#{__MODULE__}::request_batch_key [log_key: #{log_key}] Unexpected result from update query: #{inspect(r)}")
        {:error, "An error occured. Please review the logs for details. Log key: #{log_key}"}
    end
  end

  defp claim_next_batch_key_for(process_name) do
    (
      from pm in ProcessBatchKeys,
      join: batch_keys in subquery(first_batch_key_for(process_name)),
        on: batch_keys.key == pm.key,
      where: pm.process_name == ^process_name
    )
  end

  defp first_batch_key_for(process_name) do
    (
      from r in subquery(batch_keys_for(process_name)),
           where: r.row_number < 2,
           select: r.key
      )
  end

  defp release_batch_key_impl(query, update) do
    case query |> Repo.update_all(update, [returning: true]) do
      {0, []} ->
        Logger.info("#{__MODULE__}::release_batch_key Attempt to release unknown key; query: #{inspect(query)}")
        {:error, :not_found}
      {1, [%ProcessBatchKeys{
        external_id: external_id,
        key: key,
        last_completed_at: last_completed_at,
        machine: machine,
        process_name: process_name,
        started_at: started_at
      }]} ->
        {:ok, %BatchKeyInfo{
          external_id: external_id,
          key: key,
          last_completed_at: last_completed_at,
          machine: machine,
          process_name: process_name,
          started_at: started_at,
        }}
      r ->
        log_key = UUID.generate()
        Logger.error("#{__MODULE__}::release_batch_key [log_key: #{log_key}] Unexpected result from update query: #{inspect(r)}")
        {:error, "An error occured. Please review the logs for details. Log key: #{log_key}"}
    end
  end

  defp release_batch_key_update_clause() do
    [
      set: [
        machine: nil,
        started_at: nil,
        last_completed_at: Timex.now(),
        external_id: nil
      ]
    ]
  end
end
