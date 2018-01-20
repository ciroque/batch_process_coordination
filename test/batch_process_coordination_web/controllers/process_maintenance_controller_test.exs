defmodule BatchProcessCoordinationWeb.Api.V1.ProcessMaintenanceControllerTest do
  use BatchProcessCoordinationWeb.ConnCase

  import Mox

  alias BatchProcessCoordination.ProcessMaintenanceMock, as: Mock

  @process_name "#{__MODULE__}:TestProcess"

  describe "ProcessMaintenanceControllerTest" do
    setup do
      verify_on_exit!()
    end

    test "index calls list_processes on ProcessMaintenance", %{conn: conn} do
      Mock |> expect(:list_processes, fn -> {:ok, []} end)
      conn = get(conn, process_maintenance_path(conn, :index))
      assert json_response(conn, :ok) == render_json("index.json", %{process_infos: []})
    end

    test "index calls list_processes on ProcessMaintenance and renders results", %{conn: conn} do
      process_info = %{process_name: "TestProcess", key_space_size: 2112}
      Mock |> expect(:list_processes, fn -> {:ok, [process_info]} end)
      conn = get(conn, process_maintenance_path(conn, :index))
      assert json_response(conn, :ok) == render_json("index.json", %{process_infos: [process_info]})
    end

    test "delete calls unregister_process and renders not found", %{conn: conn} do
      Mock |> expect(:unregister_process, fn _process_name -> {:not_found} end)
      conn = delete(conn, process_maintenance_path(conn, :delete, "yikes"))
      assert json_response(conn, :not_found) == render_json(BatchProcessCoordinationWeb.ErrorView, "404.json", %{})
    end

    test "delete calls unregister_process on existing process_name", %{conn: conn} do
      process_info = %{process_name: @process_name, key_space_size: 247}
      Mock |> expect(:unregister_process, fn _process_name -> {:ok, process_info} end)
      conn = delete(conn, process_maintenance_path(conn, :delete, @process_name))
      assert json_response(conn, :ok) == render_json("delete.json", %{process_info: process_info})
    end

    test "post calls register_proceess for previously unregistered process name", %{conn: conn} do
      process_name = "#{__MODULE__}:PostProcess"
      process_info = %{process_name: process_name, key_space_size: 10}
      Mock |> expect(:register_process, fn pn -> assert pn === process_name; {:ok, process_info} end)
      conn = post(conn, process_maintenance_path(conn, :create, %{process_name: process_name}))
      assert json_response(conn, :created) == render_json("create.json", %{process_info: process_info})
    end

    test "post calls register_proceess for previously registered process name", %{conn: conn} do
      process_name = "#{__MODULE__}:PostProcess"
      Mock |> expect(:register_process, fn pn -> assert pn === process_name; {:name_already_exists} end)
      conn = post(conn, process_maintenance_path(conn, :create, %{process_name: process_name}))
      assert json_response(conn, :unprocessable_entity) == render_json("name_already_exists.json", %{process_name: process_name})
    end
  end

  defp render_json(template, assigns) do
    render_json(BatchProcessCoordinationWeb.Api.V1.ProcessMaintenanceView, template, assigns)
  end
  defp render_json(module, template, assigns) do
    assigns = Map.new(assigns)

    module.render(template, assigns)
    |> Poison.encode!
    |> Poison.decode!
  end
end
