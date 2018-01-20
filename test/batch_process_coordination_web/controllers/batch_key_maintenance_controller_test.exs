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

    test "index calls list_batch_keys for registered process name", %{conn: conn} do
      process_name = "#{__MODULE__}::IndexProcess"
      batch_keys = [
        %{last_completed_at: nil, external_id: nil, key: 0, machine: nil, process_name: process_name, started_at: nil},
        %{last_completed_at: nil, external_id: nil, key: 1, machine: nil, process_name: process_name, started_at: nil}
      ]

      Mock |> expect(:list_batch_keys, fn pn -> assert pn === process_name; {:ok, batch_keys} end)
      conn = get(conn, batch_key_maintenance_path(conn, :index, process_name))
      assert json_response(conn, :ok) == render_json("index.json", %{batch_keys: batch_keys})
    end

    test "post calls request_batch_key for unregistered process name", %{conn: conn} do
      process_name = "#{__MODULE__}::PostProcess"
      machine = "#{__MODULE__}::PostMachine"
      Mock
      |> expect(
        :request_batch_key,
        fn pn, mn ->
          assert pn === process_name
          assert mn === machine

          {:not_found}
        end)
      conn = post(conn, batch_key_maintenance_path(conn, :create, %{process_name: process_name, machine: machine}))
      assert json_response(conn, :not_found) == render_json(BatchProcessCoordinationWeb.ErrorView, "404.json", %{})
    end

    test "post calls request_batch_key for registered process name", %{conn: conn} do
      process_name = "#{__MODULE__}::PostProcess"
      machine = "#{__MODULE__}::PostMachine"
      batch_key = %{last_completed_at: nil, external_id: "SOME-GUID", key: 0, machine: machine, process_name: process_name, started_at: nil}
      Mock
      |> expect(
        :request_batch_key,
        fn pn, mn ->
          assert pn === process_name
          assert mn === machine

          {:ok, batch_key}
        end)
      conn = post(conn, batch_key_maintenance_path(conn, :create, %{process_name: process_name, machine: machine}))
      assert json_response(conn, :created) == render_json("create.json", %{batch_key: batch_key})
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
