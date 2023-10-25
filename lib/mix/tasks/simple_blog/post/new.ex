defmodule Mix.Tasks.SimpleBlog.Post.New do
  use Mix.Task

  @moduledoc """
  Command responsible for generate a new blog post.
  """

  @doc """
  Generates a new blog post

  ## Examples

      iex> Mix.Tasks.SimpleBlog.Post.New.run(["My first blog post"])
      "Blog post created at blog_test/_posts/yyyy-mm-dd-my-first-blog-post.md"
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
        IO.binwrite(file, "<!---" <> "\n")
        IO.binwrite(file, "filename: " <> filename <> "\n")
        IO.binwrite(file, "title: " <> title <> "\n")
        IO.binwrite(file, "date: " <> today <> "\n")
        IO.binwrite(file, "--->" <> "\n")
        File.close(file)

        Mix.shell().info("""
        Blog post created at #{full_file_path}
        """)

      {:error, :enoent} ->
        Mix.shell().info("""
        The directory #{root_directory} was not found
        """)
    end
  end

  @doc """
  Returns instructions about command usage
  """
  def usage() do
    """
    To generate a new blog post you should pass a title as string:

    $ mix simple_blog.post.new "My first blog post"
    """
  end
end
