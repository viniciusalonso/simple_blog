defmodule SimpleBlog.PostsReader do
  require Logger

  def read_from_dir({:ok, files}) do
    Logger.info("read_from_dir")

    files
    |> Enum.filter(&only_markdown_file/1)
    |> Enum.map(&read_markdown/1)
  end

  def read_from_dir({:error, :enoent}), do: raise("Directory not found")

  defp only_markdown_file(file), do: String.ends_with?(file, ".md")

  defp read_markdown(file) do
    result =
      Path.expand("blog/_posts/#{file}")
      |> File.read()

    {:ok, content} = result
    content
  end
end
