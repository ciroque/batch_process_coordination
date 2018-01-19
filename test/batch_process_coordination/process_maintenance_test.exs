defmodule BatchProcessCoordination.ProcessMaintenanceTest do
  use BatchProcessCoordination.DataCase


  alias BatchProcessCoordination.{ProcessMaintenance, Repo}

  describe "ProcessMaintenance" do
    def setup do
      delete_all_process_batch_keys()
    end

    test "Register Process creates all batch keys with default key space" do
      result = ProcessMaintenance.register_process("test one process")
      assert length(result) === 10
    end

    test "Register Process creates all batch keys with custom key space" do
      result = ProcessMaintenance.register_process("test one process", 37)
      assert length(result) === 38
    end

    test "Unregister Process deletes all batch keys" do
      created = ProcessMaintenance.register_process("test one process")
      {deleted, _} = ProcessMaintenance.unregister_process("test one process")
      assert length(created) === deleted
    end
  end
end
