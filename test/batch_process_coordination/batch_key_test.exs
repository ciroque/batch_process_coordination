defmodule BatchProcessCoordination.BatchKeyTest do
  use BatchProcessCoordination.DataCase

  import Ecto.Query

  alias BatchProcessCoordination.{BatchKey, BatchKeyInfo, Process, ProcessInfo}
  alias Ecto.UUID

  @first_process_name "BPC-Test-Process-1"
  @second_process_name "BPC-Test-Process-2"
  @base_machine_name "BPC-Test-Machine"
  @machine_one_name @base_machine_name <> "-1"

  describe "BatchKey" do
    def setup do
      delete_all_process_batch_keys()
    end

    test "returns :not_found when process is not registered" do
      assert {:error, :not_found} = BatchKey.request_batch_key("NON-EXISTENT-PROCESS", "SOME MACHINE")
    end

    test "request_batch_key obtains a batch key" do
      Process.register_process(@first_process_name)
      {:ok, %BatchKeyInfo{key: key, machine: machine, process_name: process_name}} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 0
      assert machine === @machine_one_name
      assert process_name === @first_process_name
    end

    test "even batch key distribution" do
      multiplier = 73
      {:ok, %ProcessInfo{key_space_size: key_space_size}} = Process.register_process(@first_process_name)

      1..key_space_size * multiplier
      |> Enum.map(
        fn n ->
          {:ok, batch_key} = BatchKey.request_batch_key(@first_process_name, @base_machine_name <> "-#{rem(n, multiplier)}")
          BatchKey.release_batch_key(batch_key)
          batch_key
        end
      )
      |> Enum.reduce(%{}, &update_count/2)
      |> Enum.to_list
      |> Enum.map(fn {_key, count} ->
        assert count == multiplier
      end)
    end

    defp update_count(batch_key, acc) do
      Map.update(acc, batch_key.key, 1, &(&1 + 1))
    end

    test "deplete the key space results in :no_keys_free" do
      Process.register_process(@first_process_name)

      for _ <- 0..9 do
        {:ok, %BatchKeyInfo{key: _}} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)
      end

      assert {:error, :no_keys_free} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)
      assert {:error, :no_keys_free} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)
    end

    test "request_batch_key obtains a batch key when multiple processes exist" do
      Process.register_process(@first_process_name)
      Process.register_process(@second_process_name)
      {:ok, %BatchKeyInfo{key: key, machine: machine, process_name: process_name}} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 0
      assert machine === @machine_one_name
      assert process_name === @first_process_name
    end

    test "release_batch_key for unknown external_id returns :not_found" do
      external_id = UUID.generate()
      assert {:error, :not_found} === BatchKey.release_batch_key(external_id)
    end

    test "release_batch_key for known external_id" do
      Process.register_process(@first_process_name)
      {
        :ok,
        %BatchKeyInfo{
          external_id: external_id,
          key: key,
          process_name: process_name
        }
      } = BatchKey.request_batch_key(@first_process_name, @machine_one_name)

      {
        :ok,
        %BatchKeyInfo{
          external_id: released_external_id,
          key: released_key,
          last_completed_at: released_completed_at,
          machine: released_machine,
          process_name: released_process_name,
          started_at: released_started_at,
        }
      } = BatchKey.release_batch_key(external_id)

      assert released_machine === nil
      assert released_started_at === nil
      assert released_external_id === nil

      assert released_completed_at !== nil

      assert key === released_key
      assert process_name === released_process_name
    end

    test "release_batch_key for unknown combo returns :not_found" do
      unknown_batch_key = %BatchKeyInfo{
        key: -1,
        last_completed_at: Timex.now |> Timex.shift(days: -3),
        machine: "UNKNOWN",
        process_name: "UNKNOWN",
        started_at: Timex.now,
      }

      assert {:error, :not_found} === BatchKey.release_batch_key(unknown_batch_key)
    end

    test "release_batch_key for previously released combo results in :not_found" do
      Process.register_process(@first_process_name)
      {:ok, batch_key} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)

      {:ok, _} = BatchKey.release_batch_key(batch_key)
      assert {:error, :not_found} === BatchKey.release_batch_key(batch_key)
      assert {:error, :not_found} === BatchKey.release_batch_key(batch_key)
    end

    test "release_batch_key succeeds" do
      Process.register_process(@first_process_name)
      {:ok, %BatchKeyInfo{} = batch_key} = BatchKey.request_batch_key(@first_process_name, @machine_one_name)

      {
        :ok,
        %BatchKeyInfo{
          key: key,
          process_name: process_name,
          last_completed_at: completed_at
        }
      } = BatchKey.release_batch_key(batch_key)

      assert key === 0
      assert process_name === @first_process_name
      assert completed_at !== nil
    end

    test "paired requests / releases work correctly" do
      Process.register_process(@second_process_name)

      for n <- 0..127 do
        {:ok, batch_key} = BatchKey.request_batch_key(@second_process_name, @base_machine_name <> "-#{n}")
        {:ok, released} = BatchKey.release_batch_key(batch_key)
        assert batch_key.key === released.key
      end
    end

    test "multiple batch keys in flight simulataneously" do
      {:ok, %ProcessInfo{key_space_size: key_space_size}} = Process.register_process(@first_process_name)

      batch_keys = 1..key_space_size
      |> Enum.map(
        fn n ->
          {:ok, _} = BatchKey.request_batch_key(@first_process_name, @base_machine_name <> "-#{n}")
        end
      )

      batch_keys
      |> Enum.map(
        fn {:ok, batch_key} ->
          {:ok, _} = BatchKey.release_batch_key(batch_key)
        end
      )
    end

    test "list_batch_keys returns empty list for unknown process" do
      assert BatchKey.list_batch_keys("UNKNOWN") === {:ok, []}
    end

    test "list_batch_keys returns correct list for process" do
      Process.register_process(@first_process_name)
      {:ok, %ProcessInfo{key_space_size: key_space_size}} = Process.register_process(@second_process_name)
      {:ok, batch_keys} = BatchKey.list_batch_keys(@second_process_name)
      assert length(batch_keys) === key_space_size
    end
  end
end
