defmodule BatchProcessCoordinationWeb.Api.V1.BatchKeyMaintenanceView do
  use BatchProcessCoordinationWeb, :view

  def render("create.json", %{batch_key: batch_key}) do
    %{data: batch_key}
  end

  def render("delete.json", %{batch_key: batch_key}) do
    %{data: batch_key}
  end

  def render("index.json", %{batch_keys: batch_keys}) do
    %{data: render_many(batch_keys, __MODULE__, "batch_key.json")}
  end

  def render("conflict.json", %{message: message}) do
    %{errors: [%{detail: message}]}
  end

  def render("batch_key.json", %{batch_key_maintenance: batch_key}) do
    batch_key
  end
end
