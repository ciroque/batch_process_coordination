defmodule BatchProcessCoordination.ProcessTest do
  use BatchProcessCoordination.DataCase


  alias BatchProcessCoordination.{Process, ProcessInfo, Repo}

  describe "Process" do
    def setup do
      delete_all_process_batch_keys()
    end

    test "Register Process disallows empty string as process_name" do
      assert {:error, "process_name cannot be an empty string."} == Process.register_process("")
    end

    test "Register Process disallows nil as process_name" do
      assert {:error, "process_name cannot be an empty string."} == Process.register_process(nil)
    end

    test "Register Process creates all batch keys with default key space" do
      {:ok, %{key_space_size: key_space_size}} = Process.register_process("test one process")
      assert key_space_size === 10
    end

    test "Register Process creates all batch keys with custom key space" do
      desired_key_space_size = 37
      {:ok, %{key_space_size: key_space_size}} = Process.register_process("test one process", desired_key_space_size)
      assert key_space_size === key_space_size
    end

    test "Unregister unknown Process returns :not_found" do
      {:error, :not_found} = Process.unregister_process("UNKNOWN")
    end

    test "Unregister Process deletes all batch keys" do
      {:ok, %ProcessInfo{key_space_size: registered_key_space_size}} =  Process.register_process("test one process")
      {:ok, %{key_space_size: unregistered_key_space_size}} = Process.unregister_process("test one process")
      assert registered_key_space_size === unregistered_key_space_size
    end

    test "list_processes returns empty list when nothing is preset" do
      assert Process.list_processes() === {:ok, []}
    end

    test "list_processes returns list of all processes and their key space size" do
      {:ok, _} = Process.register_process("one")
      {:ok, _} = Process.register_process("two", 7)
      {:ok, _} = Process.register_process("three", 23)

      assert Process.list_processes() == {:ok, [
        %ProcessInfo{key_space_size: 23, process_name: "three"},
        %ProcessInfo{key_space_size: 7, process_name: "two"},
        %ProcessInfo{key_space_size: 10, process_name: "one"},
      ]}
    end

    test "registering duplicate process_name is disallowed" do
      {:ok, _} =  Process.register_process("NO-DUPLICATES-ALLOWED")
      assert {:error, "process_name 'NO-DUPLICATES-ALLOWED' already exists."} == Process.register_process("NO-DUPLICATES-ALLOWED")
    end
  end
end
