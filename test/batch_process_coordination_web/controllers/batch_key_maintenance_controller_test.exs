defmodule BatchProcessCoordinationWeb.Api.V1.BatchKeyMaintenanceControllerTest do
  use BatchProcessCoordinationWeb.ConnCase

  import Mox

  alias BatchProcessCoordination.BatchKeyMaintenanceMock, as: Mock

  describe "BatchKeyMaintenanceController" do
    setup do: verify_on_exit!()

    test "index calls list_batch_keys for unregistered process name, 404 ensues", %{conn: conn} do
      process_name = "#{__MODULE__}::IndexProcess"
      Mock |> expect(:list_batch_keys, fn pn -> assert pn === process_name; {:ok, []} end)
      conn = get(conn, batch_key_maintenance_path(conn, :index, process_name))
      assert json_response(conn, :ok) == render_json("index.json", %{batch_keys: []})
    end
  end

  defp render_json(template, assigns) do
    render_json(BatchProcessCoordinationWeb.Api.V1.BatchKeyMaintenanceView, template, assigns)
  end
  defp render_json(module, template, assigns) do
    assigns = Map.new(assigns)

    module.render(template, assigns)
    |> Poison.encode!
    |> Poison.decode!
  end
end
