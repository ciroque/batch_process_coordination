defmodule BatchProcessCoordination.ProcessBehaviour do
  @type process_name_t :: String.t
  @type key_space_t :: integer()

  @type process_info_t :: %{
    process_name: String.t,
    key_space_size: integer()
  }

  @callback register_process(process_name_t)
    :: {:ok, process_info_t}
    | {:name_already_exists}
    | {:error, map()}

  @callback register_process(process_name_t, key_space_t)
    :: {:ok, process_info_t}
    | {:name_already_exists}
    | {:error, map()}

  @callback unregister_process(process_name_t)
    :: {:ok, process_info_t}
    | {:not_found}
    | {:error, map()}

  @callback list_processes() :: {:ok, list(process_info_t)}
end
