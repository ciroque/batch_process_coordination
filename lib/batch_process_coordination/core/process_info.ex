defmodule BatchProcessCoordination.ProcessInfo do
  @moduledoc false

  @type t :: %__MODULE__{
    process_name: String.t(),
    key_space_size: integer()
  }

  @enforce_keys [:process_name, :key_space_size]

  defstruct [
    :process_name,
    :key_space_size
  ]
end
