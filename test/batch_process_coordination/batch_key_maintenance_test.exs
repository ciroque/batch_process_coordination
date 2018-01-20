defmodule BatchProcessCoordination.BatchKeyMaintenanceTest do
  use BatchProcessCoordination.DataCase

  import Ecto.Query

  alias BatchProcessCoordination.{BatchKeyMaintenance, ProcessMaintenance}

  @first_process_name "BPC-Test-Process-1"
  @second_process_name "BPC-Test-Process-2"
  @base_machine_name "BPC-Test-Machine"
  @machine_one_name @base_machine_name <> "-1"

  describe "BatchKeyMaintenance" do
    def setup do
      delete_all_process_batch_keys()
    end

    test "returns :no_keys_free when process is not registered" do
      assert {:no_keys_free} = BatchKeyMaintenance.request_batch_key("NON-EXISTENT-PROCESS", "SOME MACHINE")
    end

    test "request_batch_key obtains a batch key" do
      ProcessMaintenance.register_process(@first_process_name)
      {:ok, %{key: key, machine: machine, process_name: process_name}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 0
      assert machine === @machine_one_name
      assert process_name === @first_process_name
    end

    test "even batch key distribution" do
      multiplier = 30
      {:ok, %{key_space_size: key_space_size}} = ProcessMaintenance.register_process(@first_process_name)

      1..key_space_size * multiplier
      |> Enum.map(
        fn n ->
          {:ok, batch_key} = BatchKeyMaintenance.request_batch_key(@first_process_name, @base_machine_name <> "-#{rem(n, multiplier)}")
          BatchKeyMaintenance.release_batch_key(batch_key)
          batch_key
        end
      )
      |> Enum.reduce(%{}, &update_count/2)
      |> Enum.to_list
      |> Enum.map(fn {_key, count} ->
        assert count === multiplier
      end)
    end

    defp update_count(batch_key, acc) do
      Map.update(acc, batch_key.key, 1, &(&1 + 1))
    end

    test "deplete the key space results in :no_keys_free" do
      ProcessMaintenance.register_process(@first_process_name)

      for _ <- 0..9 do
        {:ok, %{key: _}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)
      end

      assert {:no_keys_free} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)
      assert {:no_keys_free} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)
    end

    test "request_batch_key obtains a batch key when multiple processes exist" do
      ProcessMaintenance.register_process(@first_process_name)
      ProcessMaintenance.register_process(@second_process_name)
      {:ok, %{key: key, machine: machine, process_name: process_name}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 0
      assert machine === @machine_one_name
      assert process_name === @first_process_name
    end

    test "release_batch_key for unknown combo returns :not_found" do
      unknown_batch_key = %{
        process_name: "UNKNOWN",
        machine: "UNKNOWN",
        key: -1,
        started_at: Timex.now
      }

      assert {:not_found} === BatchKeyMaintenance.release_batch_key(unknown_batch_key)
    end

    test "release_batch_key for previously released combo results in :not_found" do
      ProcessMaintenance.register_process(@first_process_name)
      {:ok, batch_key} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      {:ok, _} = BatchKeyMaintenance.release_batch_key(batch_key)
      assert {:not_found} === BatchKeyMaintenance.release_batch_key(batch_key)
      assert {:not_found} === BatchKeyMaintenance.release_batch_key(batch_key)
    end

    test "release_batch_key succeeds" do
      ProcessMaintenance.register_process(@first_process_name)
      {:ok, batch_key} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      {:ok, %{key: key, machine: machine, process_name: process_name, completed_at: completed_at}} = BatchKeyMaintenance.release_batch_key(batch_key)

      assert key === 0
      assert machine === @machine_one_name
      assert process_name === @first_process_name
      assert completed_at !== nil
    end

    test "paired requests / releases work correctly" do
      ProcessMaintenance.register_process(@second_process_name)

      for n <- 0..127 do
        {:ok, batch_key} = BatchKeyMaintenance.request_batch_key(@second_process_name, @base_machine_name <> "-#{n}")
        {:ok, released} = BatchKeyMaintenance.release_batch_key(batch_key)
        assert batch_key.key === released.key
      end
    end

    test "multiple batch keys in flight simulataneously" do
      {:ok, %{key_space_size: key_space_size}} = ProcessMaintenance.register_process(@first_process_name)

      batch_keys = 1..key_space_size
      |> Enum.map(
        fn n ->
          {:ok, _} = BatchKeyMaintenance.request_batch_key(@first_process_name, @base_machine_name <> "-#{n}")
        end
      )

      batch_keys
      |> Enum.map(
        fn {:ok, batch_key} ->
          {:ok, _} = BatchKeyMaintenance.release_batch_key(batch_key)
        end
      )
    end

    test "list_batch_keys returns empty list for unknown process" do
      assert BatchKeyMaintenance.list_batch_keys("UNKNOWN") === []
    end

    test "list_batch_keys returns correct list for process" do
      ProcessMaintenance.register_process(@first_process_name)
      {:ok, %{key_space_size: key_space_size}} = ProcessMaintenance.register_process(@second_process_name)

      assert length(BatchKeyMaintenance.list_batch_keys(@second_process_name)) === key_space_size
    end
  end
end
