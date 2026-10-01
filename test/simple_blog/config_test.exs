defmodule SimpleBlog.ConfigTest do
  use ExUnit.Case
  doctest SimpleBlog.Config

  @config_path "test/blog/config.exs"

  setup do
    on_exit(fn -> File.rm(@config_path) end)
  end

  describe "read/1" do
    test "uses the light theme when config.exs does not exist" do
      assert [theme: "light"] == SimpleBlog.Config.read("test/blog")
    end

    test "reads the theme from config.exs" do
      File.write!(@config_path, ~s([theme: "sepia"]))

      assert [theme: "sepia"] == SimpleBlog.Config.read("test/blog")
    end

    test "keeps extra settings from config.exs" do
      File.write!(@config_path, ~s([name: "Vinícius"]))

      config = SimpleBlog.Config.read("test/blog")

      assert config[:theme] == "light"
      assert config[:name] == "Vinícius"
    end

    test "raises listing the available themes when the theme does not exist" do
      File.write!(@config_path, ~s([theme: "neon"]))

      assert_raise RuntimeError,
                   ~r/Theme "neon" not found.*Available themes: dark, light, sepia, solarized/,
                   fn -> SimpleBlog.Config.read("test/blog") end
    end

    test "raises when config.exs does not return a keyword list" do
      File.write!(@config_path, ~s("dark"))

      assert_raise RuntimeError, ~r/must return a keyword list/, fn ->
        SimpleBlog.Config.read("test/blog")
      end
    end
  end
end
