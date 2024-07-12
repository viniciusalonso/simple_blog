defmodule SimpleBlog.RewriteHTML.BackLinkTest do
  use ExUnit.Case
  doctest SimpleBlog.RewriteHTML.BackLink

  describe "rewrite" do
    test "rewrites link href attribute" do
      link = ~s(<a href="/" class="back-link">Back</a>)
      result = SimpleBlog.RewriteHTML.BackLink.rewrite(link)
      assert result == ~s(<a href="../../../../index.html" class="back-link">Back</a>)
    end
  end
end
