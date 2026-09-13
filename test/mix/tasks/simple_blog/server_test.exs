defmodule Mix.Tasks.SimpleBlog.ServerTest do
  use ExUnit.Case

  describe "run" do
    test "starts the application dependencies and binds the http server" do
      {:ok, pid} = Task.start(fn -> Mix.Tasks.SimpleBlog.Server.run([]) end)

      on_exit(fn -> Process.exit(pid, :shutdown) end)

      assert wait_until_listening(50)
    end
  end

  defp wait_until_listening(0), do: false

  defp wait_until_listening(retries) do
    case :gen_tcp.connect(~c"localhost", 4000, [], 200) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        true

      {:error, _reason} ->
        Process.sleep(100)
        wait_until_listening(retries - 1)
    end
  end
end
