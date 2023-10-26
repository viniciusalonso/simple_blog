defmodule Mix.Tasks.SimpleBlog.Server do
  use Mix.Task
  require Logger

  @moduledoc """
  Command responsible for a simple http server to allow local working on blog
  """

  @doc """
  Starts a local HTTP server in the port 4000

  ## Examples

      iex> Mix.Tasks.SimpleBlog.Server.run([])
      "Server running on localhost:4000"
  """
  @impl Mix.Task
  def run([]) do
    webserver = [
      {
        Plug.Cowboy,
        plug: SimpleBlog.Server, scheme: :http, options: [port: 4000]
      }
    ]

    {:ok, _} = Supervisor.start_link(webserver, strategy: :one_for_one)
    Logger.info("Server running on localhost:4000")
    Process.sleep(:infinity)
  end
end
