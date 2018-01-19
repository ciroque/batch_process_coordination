defmodule BatchProcessCoordination.ProcessMaintenance do
  @behaviour BatchProcessCoordination.ProcessMaintenanceBehaviour

  import Ecto.Query

  alias BatchProcessCoordination.ProcessModuli
  alias BatchProcessCoordination.Repo

  def register_process(process_name, key_space \\ 9) do
    for n <- 0..key_space do
      attrs = %{process_name: process_name, remainder: n}

      %ProcessModuli{}
      |> ProcessModuli.changeset(attrs)
      |> Repo.insert()
    end
  end

  def unregister_process(process_name) do
    (from pm in ProcessModuli, where: pm.process_name == ^process_name)
    |> Repo.delete_all()
  end
end
