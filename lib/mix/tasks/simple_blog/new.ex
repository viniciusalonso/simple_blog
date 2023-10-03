defmodule Mix.Tasks.SimpleBlog.New do
  use Mix.Task

  @moduledoc """
  Module responsible for generate the skeleton of a new blog.
  """

  @doc """
  It generates a new project skeleton

  ## Examples

    iex> Mix.Tasks.SimpleBlog.New.run([])
    :ok
  """
  @impl Mix.Task
  def run([]), do: Mix.shell().info(usage())

  def run([path]) do
    source = Path.expand("static")

    destination =
      Path.expand(path)
      |> Path.join(["blog"])

    case File.cp_r(source, destination) do
      {:ok, _} ->
        Mix.shell().info("Blog created with success!")

      {:error, _} ->
        Mix.shell().error("Error while create the blog in the path: #{path}")
    end
  end

  def usage() do
    """
    To generate a new blog you should pass a valid path:

    $ mix simple_blog.new .
    """
  end
end
