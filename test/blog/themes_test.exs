defmodule Blog.ThemesTest do
  use ExUnit.Case

  @variables "blog/css/plain.css"
             |> File.read!()
             |> then(&Regex.scan(~r/var\((--[a-z-]+)\)/, &1, capture: :all_but_first))
             |> List.flatten()
             |> Enum.uniq()

  for path <- Path.wildcard("blog/css/themes/*.css") do
    @path path

    test "#{Path.basename(path)} defines every variable used by plain.css" do
      theme = File.read!(@path)
      missing = Enum.reject(@variables, &(theme =~ "#{&1}:"))

      assert missing == []
    end

    test "#{Path.basename(path)} matches its copy in test/blog" do
      assert File.read!(@path) == File.read!("test/" <> @path)
    end
  end
end
