[![Latest Version](https://img.shields.io/hexpm/v/simple_blog?color=b5a3be&label=Latest+version)](https://hexdocs.pm/simple_blog)

# Simple Blog


A blog engine written in elixir to generate static blogs from markdown.

  

## Installation

```elixir

def deps do

[

{:simple_blog, "~> 0.2.0"}

]

end

```

  ## Usage

  

```console

$ git clone git@github.com:viniciusalonso/simple_blog.git

$ cd simple_blog/

$ mix deps.get
```

### Generate new blog post

```console
$ mix simple_blog.post "10 tips for new developers"
```

The file will be created at `blog/_posts/yyyy-mm-dd-10-tips-for-new-developers.md`.

### Running local server

The local http server is designed to local development of your blog. To start it run the command below:

```console
$ mix clean
$ mix simple_blog.server
```

The server will be running at `http://localhost:4000`.

### Generate static blog

To generate the static version you should run the command:

```console
$ mix simple_blog.compile
```

The command will generate a directory called `output`.

## Syntax highlighting

Code blocks in your posts are automatically highlighted using [Prism.js](https://prismjs.com/), loaded via CDN in the post template. Just use fenced code blocks with the language identifier in your markdown:

````markdown
```elixir
defmodule Counter do
  def increment(n), do: n + 1
end
```
````

## Images

Put your images inside the `blog/images/` directory (subdirectories are allowed) and reference them with an absolute path starting with `/images/`:

```markdown
![My avatar](/images/avatar.png)
```

The same works for `<img>` tags in your posts and templates:

```html
<img src="/images/avatar.png" alt="My avatar" class="avatar">
```

When you run `mix simple_blog.compile`, the whole `blog/images/` directory is copied to `output/images/`. Absolute image paths are rewritten to relative ones, so the generated blog works from any location. For example, `/images/avatar.png` becomes `./images/avatar.png` in `index.html` and `../../../../images/avatar.png` in posts.

Only `src` values that start with a single `/` are rewritten. These are left as they are:

- External URLs, such as `https://example.com/photo.jpg`
- Protocol-relative URLs, such as `//cdn.example.com/photo.jpg`
- Relative paths, such as `images/avatar.png`

The local server (`mix simple_blog.server`) serves any file under `blog/`. The content type comes from the file extension (`image/png`, `image/jpeg`, `image/svg+xml`, `image/gif`, `image/webp`, …). If a file doesn't exist, the server returns `404 Not found`.

## Default theme

The default theme is based on https://github.com/samarsault/plainwhite-jekyll.
