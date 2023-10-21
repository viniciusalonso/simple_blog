defmodule SimpleBlog.Converter.PostsTest do
  use ExUnit.Case
  doctest SimpleBlog.Converter.Posts

  describe "markdown_to_html" do
    test "transform markdown list in html" do
      input = [
        "### My Markdown Title",
        "another **markdown** test"
      ]

      expected_output = [
        "<h3>\nMy Markdown Title</h3>\n",
        "<p>\nanother <strong>markdown</strong> test</p>\n"
      ]

      html = SimpleBlog.Converter.Posts.markdown_to_html(input)
      assert expected_output == html
    end

    test "transform markdown in html" do
      input = "### My Markdown Title"
      expected_output = "<h3>\nMy Markdown Title</h3>\n"

      html = SimpleBlog.Converter.Posts.markdown_to_html(input)
      assert expected_output == html
    end

    test "with empty list returns empty one" do
      assert SimpleBlog.Converter.Posts.markdown_to_html([]) == []
    end
  end
end
