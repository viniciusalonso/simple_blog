defmodule SimpleBlog.RewriteHTML.PostsLinkTest do
  use ExUnit.Case
  doctest SimpleBlog.RewriteHTML.PostsLink

  describe "rewrite" do
    test "rewrites link to post" do
      link = ~s(<a href="/posts/?post=2024-05-22-hello-world.md" class="post-link">My post</a>)
      result = SimpleBlog.RewriteHTML.PostsLink.rewrite(link)

      assert result ==
               ~s(<a href="posts/2024/05/22/hello-world.html" class="post-link">My post</a>)
    end
  end
end
