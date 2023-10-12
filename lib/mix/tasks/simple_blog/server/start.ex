defmodule Mix.Tasks.SimpleBlog.Server.Start do
  use Mix.Task
  require Logger

  @moduledoc """
  Module responsible for a simple http server to allow local working on blog
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
