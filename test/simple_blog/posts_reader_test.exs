defmodule SimpleBlog.PostsReaderTest do
  use ExUnit.Case
  doctest SimpleBlog.PostsReader

  describe "read_from_dir" do
    setup do
      Mix.Tasks.SimpleBlog.New.run(["."])
      Mix.Tasks.SimpleBlog.Post.New.run(["my first job day"])
      Mix.Tasks.SimpleBlog.Post.New.run(["10 tips for a junior develop"])

      on_exit(fn -> File.rm_rf("blog") end)
    end

    test "returns only markdown content" do
      content = SimpleBlog.PostsReader.read_from_dir(File.ls("blog/_posts"))

      assert Enum.sort(content) ==
               Enum.sort(["## my first job day", "## 10 tips for a junior develop"])
    end

    test "raises exception when dir not exists" do
      File.rm_rf("blog")

      assert_raise RuntimeError, "Directory not found", fn ->
        content = SimpleBlog.PostsReader.read_from_dir(File.ls("blog/_posts"))
      end
    end
  end
end
