defmodule SimpleBlog.RewriteHTML.BackLink do
  import SimpleBlog.RewriteHTML

  @moduledoc """
  Module responsible for rewrite back link in post page
  """

  @doc """
  Rewrite link href attribute

  ## Examples

      iex> link = ~s(<a href="/" class="back-link">Back</a>)
      iex> SimpleBlog.RewriteHTML.BackLink.rewrite(link)
      ~s(<a href="../../../../index.html" class="back-link">Back</a>)
  """
  def rewrite(html) do
    update_tags(html, "a", fn element ->
      if has_class?(element, "back-link") do
        update_attribute(element, "href", fn
          "/" -> "../../../../index.html"
          href -> href
        end)
      else
        element
      end
    end)
  end
end
