defmodule BatchProcessCoordinationWeb.Api.V1.ProcessController do
  use BatchProcessCoordinationWeb, :controller

  action_fallback(BatchProcessCoordinationWeb.FallbackController)

  alias BatchProcessCoordination.ProcessInfo

  @process__impl Application.get_env(:batch_process_coordination, :process__impl)

  def create(conn, %{"process_name" => process_name}) do
    with {:ok, %ProcessInfo{} = process_info} <- @process__impl.register_process(process_name) do
      conn
      |> put_status(:created)
      |> render("create.json", %{process_info: process_info})
    end
  end

  def delete(conn, %{"id" => process_name}) do
    with {:ok, %ProcessInfo{} = process_info} <- @process__impl.unregister_process(process_name) do
      conn |> render("delete.json", %{process_info: process_info})
    end
  end

  def index(conn, _params) do
    with {:ok, process_infos} = @process__impl.list_processes() do
      conn |> render("index.json", %{process_infos: process_infos})
    end
  end
end
