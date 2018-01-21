defmodule BatchProcessCoordination.BatchKeyBehaviour do
  @type process_name_t :: String.t
  @type machine_name_t :: String.t
  @type key_t :: integer()
  @type last_completed_at_t :: String.t
  @type external_id_t :: String.t

  @type batch_key_result_t :: %{
    external_id: String.t,
    key: integer(),
    last_completed_at: Timex.DateTime.t,
    machine: String.t,
    process_name: String.t,
    started_at: Timex.DateTime.t
  }

  alias BatchProcessCoordination.ProcessBatchKeys

  @callback request_batch_key(process_name_t, machine_name_t)
    :: {:ok, batch_key_result_t}
    | {:error, map()}
    | {:error, String.t}

  @callback release_batch_key(batch_key_result_t)
    :: {:ok, batch_key_result_t}
    | {:error, map()}

  @callback release_batch_key(external_id_t)
    :: {:ok, batch_key_result_t}
    | {:error, map()}

  @callback list_batch_keys(process_name_t)
    :: list(ProcessBatchKeys.t)
end
