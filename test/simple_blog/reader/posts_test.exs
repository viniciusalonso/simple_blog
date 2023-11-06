defmodule SimpleBlog.Reader.PostsTest do
  use ExUnit.Case

  setup do
    Mix.Tasks.SimpleBlog.Post.run(["my first job day", "test/blog"])
    Mix.Tasks.SimpleBlog.Post.run(["10 tips for a junior develop", "test/blog"])

    on_exit(fn ->
      {:ok, files} = File.ls("test/blog/_posts/")

      full_paths =
        files
        |> Enum.filter(&String.ends_with?(&1, ".md"))

      Enum.each(full_paths, &File.rm("test/blog/_posts/" <> &1))
    end)
  end

  describe "read_from_dir" do
    test "returns only markdown content" do
      content = SimpleBlog.Reader.Posts.read_from_dir("test/blog")

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
      assert_raise RuntimeError, "Directory test_v2/blog/_posts/ not found", fn ->
        SimpleBlog.Reader.Posts.read_from_dir("test_v2/blog")
      end
    end
  end

  describe "read_post" do
    test "returns only markdown content" do
      today =
        Date.utc_today()
        |> Date.to_string()

      filename = "#{today}-my-first-job-day.md"
      content = SimpleBlog.Reader.Posts.read_post("test/blog", filename)

      assert content ==
               "<!---\nfilename: #{filename}\ntitle: my first job day\ndate: #{today}\n--->\n"
    end

    test "raises exception when dir not exists" do
      assert_raise RuntimeError, "Directory test_v2/blog/_posts/ not found", fn ->
        SimpleBlog.Reader.Posts.read_post("test_v2/blog", "my first")
      end
    end
  end
end
