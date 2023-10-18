Application.ensure_all_started(:plug)
Application.ensure_all_started(:plug_cowboy)
Application.ensure_all_started(:earmark)

defmodule SimpleBlog.Server do
  import Plug.Conn
  require Logger
  require Earmark

  def init(_options) do
    Logger.info("Initializing server ...")
  end

  def call(%Plug.Conn{request_path: "/"} = conn, _opts) do
    parse = fn body ->
      [_, title, date | _] = String.split(body, "\n")
      t = String.replace(title, "title: ", "")
      d = String.replace(date, "date: ", "")
      %SimpleBlog.Post{body: body, title: t, date: d}
    end

    posts =
      "blog"
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()
      |> Enum.map(&parse.(&1))
      |> IO.inspect()

    result =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Converter.Page.exx_to_html(posts)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
  end

  def call(
        %Plug.Conn{request_path: request_path, req_headers: [{"accept", accept} | _]} = conn,
        _opts
      ) do
    cond do
      String.contains?(accept, "text/css") -> asset_pipeline(conn, "text/css")
      String.contains?(accept, "image") -> asset_pipeline(conn, "application/png")
    end
  end

  defp html_pipeline(conn) do
    posts_html =
      "blog"
      |> SimpleBlog.Reader.Posts.read_from_dir()
      |> SimpleBlog.Converter.Posts.markdown_to_html()

    result =
      File.read("blog/index.html.eex")
      |> SimpleBlog.Converter.Page.exx_to_html(posts_html)

    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, result)
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
