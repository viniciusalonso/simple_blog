defmodule SimpleBlog.PostsTransformTest do
  use ExUnit.Case
  doctest SimpleBlog.PostsTransform

  describe "markdown_to_html" do
    test "transform markdown in html" do
      input = [
        "### My Markdown Title",
        "another **markdown** test"
      ]

      expected_output = [
        "<h3>\nMy Markdown Title</h3>\n",
        "<p>\nanother <strong>markdown</strong> test</p>\n"
      ]

      html = SimpleBlog.PostsTransform.markdown_to_html(input)
      assert expected_output == html
    end
  end
end
