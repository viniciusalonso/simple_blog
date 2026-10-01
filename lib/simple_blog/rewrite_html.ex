defmodule SimpleBlog.RewriteHTML do
  @moduledoc """
  Helpers to rewrite HTML tags in place, keeping the original formatting
  """

  @doc """
  Applies `fun` to every opening tag named `tag`, leaving the rest of the html untouched

  ## Examples

      iex> SimpleBlog.RewriteHTML.update_tags("<p>\\n  <img src=\\"a.png\\">\\n</p>", "img", &String.upcase/1)
      "<p>\\n  <IMG SRC=\\"A.PNG\\">\\n</p>"
  """
  def update_tags(html, tag, fun) do
    Regex.replace(~r/<#{tag}(?=[\s\/>])[^>]*>/i, html, fn element -> fun.(element) end)
  end

  @doc """
  Returns the value of attribute `name` in `element`, or `nil` when it is missing

  ## Examples

      iex> SimpleBlog.RewriteHTML.attribute(~s(<a href="/" class="back-link">), "class")
      "back-link"

      iex> SimpleBlog.RewriteHTML.attribute(~s(<a href="/">), "class")
      nil
  """
  def attribute(element, name) do
    case Regex.run(attribute_regex(name), element) do
      [_, _, _, value] -> value
      nil -> nil
    end
  end

  @doc """
  Replaces the value of attribute `name` in `element` with the result of `fun`

  ## Examples

      iex> SimpleBlog.RewriteHTML.update_attribute(~s(<img alt="x" src="/a.png">), "src", &("." <> &1))
      ~s(<img alt="x" src="./a.png">)
  """
  def update_attribute(element, name, fun) do
    Regex.replace(
      attribute_regex(name),
      element,
      fn _, prefix, quote, value -> prefix <> quote <> fun.(value) <> quote end,
      global: false
    )
  end

  @doc """
  Checks whether `element` has the css class `class`

  ## Examples

      iex> SimpleBlog.RewriteHTML.has_class?(~s(<a class="post-link big">), "post-link")
      true
  """
  def has_class?(element, class) do
    (attribute(element, "class") || "")
    |> String.split()
    |> Enum.member?(class)
  end

  defp attribute_regex(name), do: ~r/(\s#{name}\s*=\s*)(["'])(.*?)\2/i
end
