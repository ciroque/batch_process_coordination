defmodule BatchProcessCoordination.BatchKeyMaintenanceTest do
  use BatchProcessCoordination.DataCase

  import Ecto.Query

  alias BatchProcessCoordination.{BatchKeyMaintenance, ProcessMaintenance}

  @process_name "BPC-Test-Process"

  describe "BatchKeyMaintenance" do
    def setup do
      delete_all_process_batch_keys()
      ProcessMaintenance.register_process(@process_name)
    end

    test "request_batch_key obtains a batch key" do

    end
  end
end
