defmodule SimpleBlog.Reader.PostsTest do
  use ExUnit.Case

  setup do
    Mix.Tasks.SimpleBlog.Post.run(["my first job day", "blog_test"])
    Mix.Tasks.SimpleBlog.Post.run(["10 tips for a junior develop", "blog_test"])

    on_exit(fn ->
      {:ok, files} = File.ls("blog_test/_posts/")

      full_paths =
        files
        |> Enum.filter(&String.ends_with?(&1, ".md"))

      Enum.each(full_paths, &File.rm("blog_test/_posts/" <> &1))
    end)
  end

  describe "read_from_dir" do
    test "returns only markdown content" do
      content = SimpleBlog.Reader.Posts.read_from_dir("blog_test")

      today =
        Date.utc_today()
        |> Date.to_string()

      assert Enum.sort(content) ==
               Enum.sort([
                 "<!---\nfilename: #{today}-my-first-job-day.md\ntitle: my first job day\ndate: #{today}\n--->\n",
                 "<!---\nfilename: #{today}-10-tips-for-a-junior-develop.md\ntitle: 10 tips for a junior develop\ndate: #{today}\n--->\n"
               ])
    end

    test "raises exception when dir not exists" do
      assert_raise RuntimeError, "Directory blog_test_v2/_posts/ not found", fn ->
        SimpleBlog.Reader.Posts.read_from_dir("blog_test_v2")
      end
    end
  end

  describe "read_post" do
    test "returns only markdown content" do
      today =
        Date.utc_today()
        |> Date.to_string()

      filename = "#{today}-my-first-job-day.md"
      content = SimpleBlog.Reader.Posts.read_post("blog_test", filename)

      assert content ==
               "<!---\nfilename: #{filename}\ntitle: my first job day\ndate: #{today}\n--->\n"
    end

    test "raises exception when dir not exists" do
      assert_raise RuntimeError, "Directory blog_test_v2/_posts/ not found", fn ->
        SimpleBlog.Reader.Posts.read_post("blog_test_v2", "my first")
      end
    end
  end
end
