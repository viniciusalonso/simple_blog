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

## Default theme

The default theme is based on https://github.com/samarsault/plainwhite-jekyll.
