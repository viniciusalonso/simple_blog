defmodule SimpleBlog.RewriteHTML.ImageTest do
  use ExUnit.Case
  doctest SimpleBlog.RewriteHTML.Image

  describe "rewrite" do
    test "rewrites image src attribute" do
      image =
        ~s(<img src="/images/img_girl.jpg" alt="Girl in a jacket" title="Title" class="img-circle"/>)

      path = "./"
      result = SimpleBlog.RewriteHTML.Image.rewrite(image, path)

      assert result ==
               ~s(<img src="./images/img_girl.jpg" alt="Girl in a jacket" title="Title" class="img-circle"/>)
    end

    test "rewrites src when it is not the first attribute" do
      image = ~s(<img alt="Girl" src="/images/img_girl.jpg"/>)

      result = SimpleBlog.RewriteHTML.Image.rewrite(image, "../../../../")

      assert result == ~s(<img alt="Girl" src="../../../../images/img_girl.jpg"/>)
    end

    test "keeps external urls untouched" do
      image = ~s(<img src="https://example.com/a.png" alt="External"/>)

      assert SimpleBlog.RewriteHTML.Image.rewrite(image, "../../../../") == image
    end

    test "keeps protocol-relative urls untouched" do
      image = ~s(<img src="//example.com/a.png" alt="External"/>)

      assert SimpleBlog.RewriteHTML.Image.rewrite(image, "../../../../") == image
    end

    test "keeps relative paths untouched" do
      image = ~s(<img src="images/avatar.png" alt="Relative"/>)

      assert SimpleBlog.RewriteHTML.Image.rewrite(image, "../../../../") == image
    end

    test "keeps img without src untouched" do
      image = ~s(<img alt="No source"/>)

      assert SimpleBlog.RewriteHTML.Image.rewrite(image, "./") == image
    end
  end
end
