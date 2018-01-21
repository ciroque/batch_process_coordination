defmodule BatchProcessCoordinationWeb.Api.V1.ProcessController do
  use BatchProcessCoordinationWeb, :controller

  alias BatchProcessCoordination.ProcessInfo

  @process__impl Application.get_env(:batch_process_coordination, :process__impl)

  def create(conn, %{"process_name" => process_name}) do
    case @process__impl.register_process(process_name) do
      {:ok, %ProcessInfo{} = process_info} ->
        conn
        |> put_status(:created)
        |> render("create.json", %{process_info: process_info})

      {:name_already_exists} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render("name_already_exists.json", %{process_name: process_name})
    end
  end

  def delete(conn, %{"id" => process_name}) do
    case @process__impl.unregister_process(process_name) do
      {:ok, %ProcessInfo{} = process_info} ->
        conn |> render("delete.json", %{process_info: process_info})
      {:not_found} -> ## WTF doesn't ErrorView work??
        conn
        |> put_status(:not_found)
        |> render(BatchProcessCoordinationWeb.ErrorView, "404.json", %{})
    end
  end

  def index(conn, _params) do
    with {:ok, process_infos} = @process__impl.list_processes() do
      conn |> render("index.json", %{process_infos: process_infos})
    end
  end
end
