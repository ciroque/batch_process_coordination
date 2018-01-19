defmodule BatchProcessCoordination.ProcessMaintenanceTest do
  use BatchProcessCoordination.DataCase


  alias BatchProcessCoordination.{ProcessMaintenance, Repo}

  describe "ProcessMaintenance" do
    def setup do
      delete_all_process_batch_keys()
    end

    test "Register Process creates all batch keys with default key space" do
      {:ok, %{key_space_size: key_space_size}} = ProcessMaintenance.register_process("test one process")
      assert key_space_size === 10
    end

    test "Register Process creates all batch keys with custom key space" do
      desired_key_space_size = 37
      {:ok, %{key_space_size: key_space_size}} = ProcessMaintenance.register_process("test one process", desired_key_space_size)
      assert key_space_size === key_space_size
    end

    test "Unregister Process deletes all batch keys" do
      {:ok, %{key_space_size: key_space_size}} =  ProcessMaintenance.register_process("test one process")
      {deleted, _} = ProcessMaintenance.unregister_process("test one process")
      assert key_space_size === deleted
    end

    test "list_processes returns empty list when nothing is preset" do
      assert ProcessMaintenance.list_processes() === {:ok, []}
    end

    test "list_processes returns list of all processes and their key space size" do
      {:ok, _} = ProcessMaintenance.register_process("one")
      {:ok, _} = ProcessMaintenance.register_process("two", 7)
      {:ok, _} = ProcessMaintenance.register_process("three", 23)

      assert ProcessMaintenance.list_processes() === {:ok, [
        %{key_space_size: 23, process_name: "three"},
        %{key_space_size: 7, process_name: "two"},
        %{key_space_size: 10, process_name: "one"},
      ]}
    end
  end
end
