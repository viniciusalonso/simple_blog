defmodule SimpleBlog.Reader.PostsTest do
  use ExUnit.Case

  describe "read_from_dir" do
    setup do
      Mix.Tasks.SimpleBlog.Post.New.run(["my first job day", "blog_test"])
      Mix.Tasks.SimpleBlog.Post.New.run(["10 tips for a junior develop", "blog_test"])

      on_exit(fn ->
        {:ok, files} = File.ls("blog_test/_posts/")

        full_paths =
          files
          |> Enum.filter(&String.ends_with?(&1, ".md"))

        Enum.each(full_paths, &File.rm("blog_test/_posts/" <> &1))
      end)
    end

    test "returns only markdown content" do
      content = SimpleBlog.Reader.Posts.read_from_dir("blog_test")

      assert Enum.sort(content) ==
               Enum.sort([
                 "<!---\ntitle: my first job day\ndate: 2023-10-18\n--->\n## my first job day",
                 "<!---\ntitle: 10 tips for a junior develop\ndate: 2023-10-18\n--->\n## 10 tips for a junior develop"
               ])
    end

    test "raises exception when dir not exists" do
      assert_raise RuntimeError, "Directory blog_test_v2/_posts/ not found", fn ->
        SimpleBlog.Reader.Posts.read_from_dir("blog_test_v2")
      end
    end
  end
end
