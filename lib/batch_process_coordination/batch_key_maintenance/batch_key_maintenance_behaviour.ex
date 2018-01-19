defmodule BatchProcessCoordination.BatchKeyMaintenanceBehaviour do
  @type process_name_t :: String.t
  @type machine_name_t :: String.t
  @type modulus_t :: integer()
  @type last_completed_at_t :: String.t

  alias BatchProcessCoordination.ProcessBatchKeys

  @callback request_batch_key(process_name_t, machine_name_t) :: {:ok, modulus_t} | {:error, map()}

  @callback release_batch_key(process_name_t, modulus_t) :: {:ok, last_completed_at_t} | {:error, map()}

  @callback list_batch_keys(process_name_t) :: list(ProcessBatchKeys.t)
end
