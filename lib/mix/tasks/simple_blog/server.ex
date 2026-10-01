defmodule Mix.Tasks.SimpleBlog.Server do
  use Mix.Task
  require Logger

  @default_port 4000

  @shortdoc "Starts a local server to preview the blog"

  @moduledoc """
  Starts a local HTTP server to preview the blog while you write.

  Pages are rendered from `blog/` on every request, so changes to posts,
  templates and stylesheets show up after reloading the browser.

      $ mix simple_blog.server
      $ mix simple_blog.server --port 4001

  ## Options

    * `--port` - the port to listen on. Defaults to `#{@default_port}`.
  """

  @impl Mix.Task
  def run(args) do
    port = parse_port(args)

    Mix.Task.run("app.start")

    webserver = [
      {
        Plug.Cowboy,
        plug: SimpleBlog.Server, scheme: :http, options: [port: port]
      }
    ]

    case start_webserver(webserver) do
      {:ok, _} ->
        Logger.info("Server running on localhost:#{port}")
        Process.sleep(:infinity)

      {:error, reason} ->
        if port_in_use?(reason) do
          Mix.raise(
            "Port #{port} is already in use. " <>
              "Stop the process using it or pick another port, e.g. --port #{port + 1}"
          )
        else
          Mix.raise("Could not start the server on port #{port}: #{inspect(reason)}")
        end
    end
  end

  # A listener that fails to start also sends an exit signal, which would kill
  # this process before we could report the error
  defp start_webserver(webserver) do
    trap_exit = Process.flag(:trap_exit, true)
    result = Supervisor.start_link(webserver, strategy: :one_for_one)
    Process.flag(:trap_exit, trap_exit)

    with {:error, _reason} <- result do
      receive do
        {:EXIT, _pid, _reason} -> :ok
      after
        0 -> :ok
      end

      result
    end
  end

  defp parse_port(args) do
    case OptionParser.parse(args, strict: [port: :integer]) do
      {opts, [], []} ->
        port = Keyword.get(opts, :port, @default_port)

        if port in 1..65_535,
          do: port,
          else: Mix.raise("Invalid port #{port}. Use a number between 1 and 65535")

      {_opts, _positional, _invalid} ->
        Mix.raise("""
        Invalid arguments. Usage:

            $ mix simple_blog.server [--port PORT]
        """)
    end
  end

  defp port_in_use?({:shutdown, {:failed_to_start_child, _, reason}}),
    do: port_in_use?(reason)

  defp port_in_use?({:listen_error, _, :eaddrinuse}), do: true
  defp port_in_use?(_reason), do: false
end
