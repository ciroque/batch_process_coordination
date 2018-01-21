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
    case @batch_key__impl.request_batch_key(process_name, machine) do
      {:ok, %BatchKeyInfo{} = batch_key} ->
        conn
        |> put_status(:created)
        |> render("create.json", %{batch_key: batch_key})
      {:no_keys_free} ->
        conn
        |> put_status(:conflict)
        |> render("conflict.json", %{message: "All keys for process '#{process_name}' have been reserved."})
      {:not_found} ->
        {:error, :not_found}
    end
  end

  def delete(conn, %{"external_id" => external_id}) do
    case @batch_key__impl.release_batch_key(external_id) do
      {:ok, %BatchKeyInfo{} = batch_key} ->
        conn |> render("delete.json", %{batch_key: batch_key})
      {:not_found} ->
        {:error, :not_found}
    end
  end
end
