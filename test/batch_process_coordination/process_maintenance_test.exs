defmodule BatchProcessCoordination.ProcessMaintenanceTest do
  use BatchProcessCoordination.DataCase

  import Ecto.Query

  alias BatchProcessCoordination.{ProcessMaintenance, ProcessModuli, Repo}

  describe "ProcessMaintenance" do
    def setup do
      (from pm in ProcessModuli, select: pm) |> Repo.delete_all()
    end

    test "Register Process creates all moduli with default key space" do
      result = ProcessMaintenance.register_process("test one process")
      assert length(result) === 10
    end

    test "Register Process creates all moduli with custom key space" do
      result = ProcessMaintenance.register_process("test one process", 37)
      assert length(result) === 38
    end

    test "Unregister Process deletes all moduli" do
      created = ProcessMaintenance.register_process("test one process")
      {deleted, _} = ProcessMaintenance.unregister_process("test one process")
      assert length(created) === deleted
    end
  end
end
