defmodule BatchProcessCoordinationWeb.Api.V1.BatchKeyMaintenanceView do
  use BatchProcessCoordinationWeb, :view

  def render("index.json", %{batch_keys: batch_keys}) do
    %{data: render_many(batch_keys, __MODULE__, "batch_key.json")}
  end

  def render("batch_key.json", %{batch_key_maintenance: batch_key}) do
    batch_key
  end
end
