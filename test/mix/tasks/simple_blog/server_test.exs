defmodule Mix.Tasks.SimpleBlog.ServerTest do
  use ExUnit.Case
  import ExUnit.CaptureLog

  describe "run" do
    test "starts the http server on the port given by --port" do
      port = free_port()

      {:ok, pid} =
        Task.start(fn -> Mix.Tasks.SimpleBlog.Server.run(["--port", Integer.to_string(port)]) end)

      assert wait_until_listening(port, 50)

      stop_server(pid)
    end

    test "explains how to pick another port when the port is in use" do
      {:ok, socket} = :gen_tcp.listen(0, [])
      {:ok, port} = :inet.port(socket)
      on_exit(fn -> :gen_tcp.close(socket) end)

      capture_log(fn ->
        assert_raise Mix.Error, ~r/Port #{port} is already in use.*--port #{port + 1}/, fn ->
          Mix.Tasks.SimpleBlog.Server.run(["--port", Integer.to_string(port)])
        end
      end)
    end

    test "rejects ports out of range" do
      assert_raise Mix.Error, ~r/Invalid port 70000/, fn ->
        Mix.Tasks.SimpleBlog.Server.run(["--port", "70000"])
      end
    end

    test "shows the usage for unknown arguments" do
      for args <- [["--prot", "4001"], ["--port", "abc"], ["blog"]] do
        assert_raise Mix.Error, ~r/mix simple_blog.server \[--port PORT\]/, fn ->
          Mix.Tasks.SimpleBlog.Server.run(args)
        end
      end
    end
  end

  test "has a short description for mix help" do
    assert Mix.Task.shortdoc(Mix.Tasks.SimpleBlog.Server) ==
             "Starts a local server to preview the blog"
  end

  defp stop_server(pid) do
    Process.exit(pid, :shutdown)
    :ok = Plug.Cowboy.shutdown(SimpleBlog.Server.HTTP)
  end

  defp free_port do
    {:ok, socket} = :gen_tcp.listen(0, [])
    {:ok, port} = :inet.port(socket)
    :gen_tcp.close(socket)
    port
  end

  defp wait_until_listening(_port, 0), do: false

  defp wait_until_listening(port, retries) do
    case :gen_tcp.connect(~c"localhost", port, [], 200) do
      {:ok, socket} ->
        :gen_tcp.close(socket)
        true

      {:error, _reason} ->
        Process.sleep(100)
        wait_until_listening(port, retries - 1)
    end
  end
end
