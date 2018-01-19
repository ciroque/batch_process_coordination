defmodule BatchProcessCoordination.ProcessMaintenanceBehaviour do
  @type process_name_t :: String.t
  @type key_space_t :: integer()

  @callback register_process(process_name_t, key_space_t) :: {:ok} | {:error, map()}

  @callback unregister_process(process_name_t) :: {:ok} | {:error, map()}
end
