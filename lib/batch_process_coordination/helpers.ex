defmodule BatchProcessCoordination.Helpers do
  import Ecto.Query

  alias BatchProcessCoordination.{ProcessBatchKeys, Repo}

  def process_name_exists(process_name) do
    ((from pm in ProcessBatchKeys, where: pm.process_name ==^process_name, select: count(pm.id)) |> Repo.one) > 0
  end
end
