# Popkernel

**Functions that should be in Kernel but aren't**

This library is an experiment:
- To apply monadic and related patterns but in an idiomatic Elixir way.
- To take some inspiration from Haskell's approach to Monads
- To take some inspiration from Rust's helpers
- More generally, to add things that seem like they should already be in the `Kernel` library and aren't

There are other libraries that have tried to show how you can replace existing Erlang patterns like {:ok, value} with
structs that are closer to what other languages use, but this takes us too far away from how the rest of Elixir works.

Instead, what if we could add some small helper functions, macros and modules that give a bit of that functionality in
ways that more naturally fit with other Elixir code?
