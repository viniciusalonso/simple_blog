defmodule SimpleBlog.Reader.PostsTest do
  use ExUnit.Case
  # doctest SimpleBlog.Reader.Posts

  describe "read_from_dir" do
    setup do
      Mix.Tasks.SimpleBlog.Post.New.run(["my first job day", "blog_test"])
      Mix.Tasks.SimpleBlog.Post.New.run(["10 tips for a junior develop", "blog_test"])

      # on_exit(fn -> File.rm_rf("blog_test") end)
    end

    test "returns only markdown content" do
      content = SimpleBlog.Reader.Posts.read_from_dir("blog_test")

      assert Enum.sort(content) ==
               Enum.sort(["## my first job day", "## 10 tips for a junior develop"])
    end

    test "raises exception when dir not exists" do
      assert_raise RuntimeError, "Directory blog_test_v2/_posts/ not found", fn ->
        SimpleBlog.Reader.Posts.read_from_dir("blog_test_v2")
      end
    end
  end
end
