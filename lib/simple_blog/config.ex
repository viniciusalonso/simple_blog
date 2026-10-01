defmodule SimpleBlog.Config do
  @moduledoc """
  Module responsible for reading the blog settings from `config.exs`
  """

  @defaults [theme: "light"]

  @doc """
  Reads `config.exs` from the blog root directory, filling missing keys with defaults.

  The file is optional and must evaluate to a keyword list. The configured theme
  must match a file in `css/themes/`.

  ## Examples

      iex> SimpleBlog.Config.read("test/blog")
      [theme: "light"]
  """
  def read(root_directory) do
    config =
      @defaults
      |> Keyword.merge(read_file(root_directory <> "/config.exs"))

    validate_theme!(config[:theme], root_directory)
    config
  end

  @doc """
  Lists the themes available in `css/themes/`

  ## Examples

      iex> SimpleBlog.Config.themes("test/blog")
      ["dark", "light", "sepia", "solarized"]
  """
  def themes(root_directory) do
    (root_directory <> "/css/themes/*.css")
    |> Path.wildcard()
    |> Enum.map(&Path.basename(&1, ".css"))
    |> Enum.sort()
  end

  defp read_file(path) do
    if File.exists?(path) do
      case Code.eval_file(path) do
        {config, _bindings} when is_list(config) ->
          if Keyword.keyword?(config), do: config, else: raise_invalid_file(path)

        _ ->
          raise_invalid_file(path)
      end
    else
      []
    end
  end

  defp raise_invalid_file(path) do
    raise "#{path} must return a keyword list, such as [theme: \"light\"]"
  end

  defp validate_theme!(theme, root_directory) do
    themes = themes(root_directory)

    unless theme in themes do
      raise "Theme #{inspect(theme)} not found in #{root_directory}/css/themes/. " <>
              "Available themes: #{Enum.join(themes, ", ")}"
    end
  end
end
