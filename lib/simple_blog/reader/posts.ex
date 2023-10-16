defmodule SimpleBlog.Reader.Posts do
  require Logger

  def read_from_dir(root_directory) do
    posts_directory = root_directory <> "/_posts/"

    case File.ls(posts_directory) do
      {:ok, files} -> pipeline(posts_directory, files)
      {:error, :enoent} -> raise("Directory #{posts_directory} not found")
    end
  end

  defp pipeline(_posts_directory, []), do: []

  defp pipeline(posts_directory, files) do
    files
    |> Enum.map(fn file -> full_path(file, posts_directory) end)
    |> Enum.filter(&only_markdown_file/1)
    |> Enum.map(&read_markdown/1)
  end

  defp full_path(file, posts_directory) do
    Path.expand(posts_directory <> file)
  end

  defp only_markdown_file(file), do: String.ends_with?(file, ".md")

  defp read_markdown(file) do
    result = File.read(file)

    {:ok, content} = result
    content
  end
end
