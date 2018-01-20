defmodule BatchProcessCoordinationWeb.Api.V1.BatchKeyMaintenanceController do
  use BatchProcessCoordinationWeb, :controller

  @batch_key_maintenance_impl Application.get_env(:batch_process_coordination, :batch_key_maintenance_impl)

  def index(conn, %{"process_name" => process_name}) do
    with {:ok, batch_keys} = @batch_key_maintenance_impl.list_batch_keys(process_name) do
      conn |> render("index.json", %{batch_keys: batch_keys})
    end
  end
end
