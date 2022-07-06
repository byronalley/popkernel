# Popcorn

**Functions that should be in Kernel but aren't**

It seems like a rite of passage for Elixir developers to code some sort of monadic wrapper library. This is a bit of that.

A lot of this little library is an attempt to write helpers that apply monad patterns but in what should feel like an idiomatic Elixir way.

But more generally it's an experiment looking at things that seem like they should already be in the `Kernel` library and aren't, so the intent is that this library should be use via `import` so that the functions feel like part of the language.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `popcorn` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:popcorn, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/popcorn>.

