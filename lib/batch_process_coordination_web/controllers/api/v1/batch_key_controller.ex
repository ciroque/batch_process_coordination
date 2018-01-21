defmodule BatchProcessCoordinationWeb.Api.V1.BatchKeyController do
  use BatchProcessCoordinationWeb, :controller

  alias BatchProcessCoordination.BatchKeyInfo

  @batch_key__impl Application.get_env(:batch_process_coordination, :batch_key__impl)

  action_fallback(BatchProcessCoordinationWeb.FallbackController)

  def index(conn, %{"process_name" => process_name}) do
    with {:ok, batch_keys} = @batch_key__impl.list_batch_keys(process_name) do
      conn |> render("index.json", %{batch_keys: batch_keys})
    end
  end

  def create(conn, %{"process_name" => process_name, "machine" => machine}) do
    with {:ok, %BatchKeyInfo{} = batch_key} <- @batch_key__impl.request_batch_key(process_name, machine) do
      conn
      |> put_status(:created)
      |> render("create.json", %{batch_key: batch_key})
    end
  end

  def delete(conn, %{"external_id" => external_id}) do
    with {:ok, %BatchKeyInfo{} = batch_key} <- @batch_key__impl.release_batch_key(external_id) do
      conn |> render("delete.json", %{batch_key: batch_key})
    end
  end
end
