defmodule BatchProcessCoordinationWeb.Api.V1.BatchKeyMaintenanceController do
  use BatchProcessCoordinationWeb, :controller

  @batch_key_maintenance_impl Application.get_env(:batch_process_coordination, :batch_key_maintenance_impl)

  action_fallback(BatchProcessCoordinationWeb.FallbackController)

  def index(conn, %{"process_name" => process_name}) do
    with {:ok, batch_keys} = @batch_key_maintenance_impl.list_batch_keys(process_name) do
      conn |> render("index.json", %{batch_keys: batch_keys})
    end
  end

  def create(conn, %{"process_name" => process_name, "machine" => machine}) do
    case @batch_key_maintenance_impl.request_batch_key(process_name, machine) do
      {:ok, batch_key} ->
        conn
        |> put_status(:created)
        |> render("create.json", %{batch_key: batch_key})
      {:not_found} ->
        {:error, :not_found}
    end
  end
end
