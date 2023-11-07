Application.ensure_all_started(:plug)
Application.ensure_all_started(:plug_cowboy)
Application.ensure_all_started(:earmark)

defmodule SimpleBlog.Server do
  import Plug.Conn
  require Logger
  require Earmark

  @moduledoc """
  Module responsible for handle HTTP requests
  """

  @doc """
  Initializes server passing initial params
  """
  def init(_options) do
    Logger.info("Initializing server ...")
  end

  @doc """
  Handle HTTP requests.
  """
  def call(%Plug.Conn{request_path: "/posts/", query_string: query_string} = conn, _opts) do
    postname =
      query_string
      |> String.split("=")
      |> List.last()

    post =
      "blog"
      |> SimpleBlog.Reader.Posts.read_post(postname)
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> SimpleBlog.Post.parse()

    result =
      File.read("blog/post.html.eex")
      |> SimpleBlog.Converter.Page.eex_to_html(post)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
  end

  def call(%Plug.Conn{request_path: "/"} = conn, _opts) do
    posts =
      "blog"
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> Enum.map(&SimpleBlog.Post.parse(&1))

    result =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Converter.Page.eex_to_html(posts)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
  end

  def call(
        %Plug.Conn{request_path: _request_path, req_headers: [{"accept", accept} | _]} = conn,
        _opts
      ) do
    cond do
      String.contains?(accept, "text/css") -> asset_pipeline(conn, "text/css")
      String.contains?(accept, "image") -> asset_pipeline(conn, "application/png")
    end
  end

  defp asset_pipeline(%Plug.Conn{request_path: request_path} = conn, content_type) do
    Logger.info(request_path)

    content =
      case File.read("blog" <> request_path) do
        {:ok, content} -> content
        {:error, :eisdir} -> request_path
      end

    Logger.info(request_path)

    conn
    |> put_resp_content_type(content_type)
    |> send_resp(200, content)
  end
end
