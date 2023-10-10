defmodule SimpleBlog.Renderer do
  def exx_to_html({:ok, body}, posts_html) do
    quoted = EEx.compile_string(body)

    case Code.eval_quoted(quoted, files: posts_html) do
      {result, _bindings} -> result
    end
  end
end
