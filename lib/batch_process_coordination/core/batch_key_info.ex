defmodule BatchProcessCoordination.BatchKeyInfo do
  @moduledoc false

  @type t :: %__MODULE__{
    external_id: String.t,
    key: integer(),
    last_completed_at: Timex.DateTime.t,
    machine: String.t,
    process_name: String.t,
    started_at: Timex.DateTime.t
  }

  @enforce_keys [:process_name]

  defstruct [
    :external_id,
    :key,
    :last_completed_at,
    :machine,
    :process_name,
    :started_at
  ]
end
