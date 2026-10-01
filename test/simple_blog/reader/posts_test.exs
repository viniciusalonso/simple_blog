defmodule SimpleBlog.Reader.PostsTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    capture_io(fn ->
      Mix.Tasks.SimpleBlog.Gen.Post.run(["my first job day", "test/blog"])
      Mix.Tasks.SimpleBlog.Gen.Post.run(["10 tips for a junior develop", "test/blog"])
    end)

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
        NaiveDateTime.local_now()
        |> NaiveDateTime.to_date()
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
        NaiveDateTime.local_now()
        |> NaiveDateTime.to_date()
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

    test "raises exception when post not exists" do
      assert_raise RuntimeError, "Post test/blog/_posts/missing.md not found", fn ->
        SimpleBlog.Reader.Posts.read_post("test/blog", "missing.md")
      end
    end
  end
end
