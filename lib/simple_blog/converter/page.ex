defmodule SimpleBlog.Converter.Page do
  @moduledoc """
  Module responsible for convert pages from eex to html
  """

  @doc """
  Convert eex file to html

  ## Examples

      iex> posts = [%SimpleBlog.Post{title: "post 1"}, %SimpleBlog.Post{title: "post 2"}]
      iex> SimpleBlog.Converter.Page.eex_to_html({:ok, "<%= for post <- posts do %><%= post.title %><% end %>"}, posts)
      "post 1post 2"

      iex> post = %SimpleBlog.Post{title: "post 1"}
      iex> SimpleBlog.Converter.Page.eex_to_html({:ok, "<%= post.title %>"}, post)
      "post 1"

      iex> post = %SimpleBlog.Post{title: "post 1"}
      iex> SimpleBlog.Converter.Page.eex_to_html({:ok, "<%= config[:theme] %>"}, post, theme: "dark")
      "dark"
  """
  def eex_to_html(body, posts, config \\ [])

  def eex_to_html({:ok, body}, posts, config) when is_list(posts) do
    quoted = EEx.compile_string(body)

    case Code.eval_quoted(quoted, posts: posts, config: config) do
      {result, _bindings} -> result
    end
  end

  def eex_to_html({:ok, body}, post, config) do
    quoted = EEx.compile_string(body)

    case Code.eval_quoted(quoted, post: post, config: config) do
      {result, _bindings} -> result
    end
  end
end
