# TODO

[X] 1. `ok()`: take a value and wrap it in `{:ok, value}`
    - [ ] Implement ok() as macro
[X] 2. `error()`: take a value and wrap it in `{:error, value}`
   - [ ] Implement ok() as macro
[ ] 3. `id()`: function that returns the value it's given
   - [ ] Implement as alias to Function.identity/1
[ ] 4. `tuple_wrap()`: macro that runs whatever you give it and returns {:error, ???} if it raises, otherwise {:ok, value}
[ ] 5. `monad()` or something, maybe using that one safe operator, what's it?
[ ] 	- Take a function and a maybe value (status tuple)
[ ] 	- If it's an error tuple, pass it through
[ ] 	- If it's an ok tuple, run the value through the function, which presumably returns another tuple
[ ] 6. Create a Functor Protocol with an fmap implementation and some kind of <$> style operator
   - [ ] Implement for lists: just Enum.map
   - [ ] Implement for result tuples
   - [ ] Implement for BitString so that you can do fmap("foo", &String.upcase/1) and get "FOO" instead of ["F", "O", "O"]
[ ] 7. unwrap functions
[ ]   a. `unwrap/1`
[ ]   b. `unwrap_or/1`
[ ] 9. Implement Enumerable for String
   - [ ] Use `Enumerable.impl_for("")` to avoid re-implementing via macro
[ ] 10. Create a pseudo Enum type
