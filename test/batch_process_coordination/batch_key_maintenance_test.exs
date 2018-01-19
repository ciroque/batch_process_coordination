defmodule BatchProcessCoordination.BatchKeyMaintenanceTest do
  use BatchProcessCoordination.DataCase

  import Ecto.Query

  alias BatchProcessCoordination.{BatchKeyMaintenance, ProcessMaintenance}

  @first_process_name "BPC-Test-Process-1"
  @second_process_name "BPC-Test-Process-2"
  @machine_one_name "BPC-Test-Machine-1"

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

    test "request_batch_key obtains successive batch keys" do
      ProcessMaintenance.register_process(@first_process_name)
      {:ok, %{key: key, machine: machine, process_name: process_name}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 0
      assert machine === @machine_one_name
      assert process_name === @first_process_name

      {:ok, %{key: key, machine: machine, process_name: process_name}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 1
      assert machine === @machine_one_name
      assert process_name === @first_process_name

      {:ok, %{key: key, machine: machine, process_name: process_name}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)

      assert key === 2
      assert machine === @machine_one_name
      assert process_name === @first_process_name
    end

    test "deplete the key space results in :no_keys_free" do
      ProcessMaintenance.register_process(@first_process_name)

      for n <- 0..9 do
        {:ok, %{key: key}} = BatchKeyMaintenance.request_batch_key(@first_process_name, @machine_one_name)
        assert key === n
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
  end
end
