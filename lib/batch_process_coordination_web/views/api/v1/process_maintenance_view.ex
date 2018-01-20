defmodule BatchProcessCoordinationWeb.Api.V1.ProcessMaintenanceView do
  use BatchProcessCoordinationWeb, :view

  def render("create.json", %{process_info: process_info}) do
    %{data: process_info}
  end

  def render("delete.json", %{process_info: process_info}) do
    %{data: process_info}
  end

  def render("index.json", %{process_infos: process_infos}) do
    %{data: render_many(process_infos, __MODULE__, "process_info.json")}
  end

  def render("name_already_exists.json", %{process_name: process_name}) do
    %{errors: %{detail: "Process name already exists", process_name: process_name}}
  end

  def render("process_info.json", %{process_maintenance: process_info}) do
    process_info
  end
end
