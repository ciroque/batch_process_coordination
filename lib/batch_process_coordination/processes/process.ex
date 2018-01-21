defmodule BatchProcessCoordination.Process do
  @behaviour BatchProcessCoordination.ProcessBehaviour

  import BatchProcessCoordination.Helpers
  import Ecto.Query

  alias BatchProcessCoordination.{ProcessBatchKeys, ProcessInfo, Repo}

  @process_name_cannot_be_empty "process_name cannot be an empty string."

  def register_process(process_name, key_space_size \\ 10)
  def register_process(process_name, _key_space_size) when is_nil(process_name) do
    {:error, %{detail: @process_name_cannot_be_empty}}
  end
  def register_process("" = _process_name, _key_space_size) do
    {:error, %{detail: @process_name_cannot_be_empty}}
  end
  def register_process(process_name, key_space_size) do
    cond do
      process_name_exists(process_name) -> {:name_already_exists}
      true -> create_process_key_space(process_name, key_space_size)
    end
  end

  def unregister_process(process_name) do
    cond do
      process_name_exists(process_name) ->
        delete_process_key_space(process_name)
      true ->
        {:not_found}
    end
  end

  def list_processes() do
    processes = (
      from pm in ProcessBatchKeys,
      group_by: pm.process_name,
      select: %ProcessInfo{
        process_name: pm.process_name,
        key_space_size: count(pm.id)
      }
    ) |> Repo.all
    {:ok, processes}
  end

  defp create_process_key_space(process_name, key_space_size) do
    batch_keys = for n <- 0..key_space_size - 1 do
      attrs = %{
        process_name: process_name,
        key: n,
        last_completed_at: Timex.now() |> Timex.shift(days: -1)
      }

      %ProcessBatchKeys{}
      |> ProcessBatchKeys.changeset(attrs)
      |> Repo.insert()
    end

    {:ok, %ProcessInfo{process_name: process_name, key_space_size: length(batch_keys)}}
  end

  defp delete_process_key_space(process_name) do
    {count, _} = (from pm in ProcessBatchKeys, where: pm.process_name == ^process_name)
    |> Repo.delete_all()

    {:ok, %ProcessInfo{process_name: process_name, key_space_size: count}}
  end
end
