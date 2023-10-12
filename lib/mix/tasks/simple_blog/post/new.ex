defmodule Mix.Tasks.SimpleBlog.Post.New do
  use Mix.Task

  @moduledoc """
  Module responsible for generate a new blog post.
  """

  @doc """
  It generates a new blog post

  ## Examples

    # iex> Mix.Tasks.SimpleBlog.Post.New.run(["My first blog post"])
    # :ok
  """
  @impl Mix.Task
  def run([]), do: Mix.shell().info(usage())

  def run([title]), do: run([title, "blog"])

  def run([title, root_directory]) do
    today =
      Date.utc_today()
      |> Date.to_string()

    filename = SimpleBlog.Post.generate_filename(%SimpleBlog.Post{title: title, date: today})
    full_file_path = root_directory <> "/_posts/" <> filename

    case File.open(full_file_path, [:write]) do
      {:ok, file} ->
        IO.binwrite(file, "## " <> title)
        File.close(file)

      {:error, :enoent} ->
        Mix.shell().info("""
        The directory #{root_directory} was not found
        """)
    end
  end

  def usage() do
    """
    To generate a new blog post you should pass a title as string:

    $ mix simple_blog.post.new "My first blog post"
    """
  end
end
