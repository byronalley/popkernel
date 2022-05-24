# TODO

1. `ok()`: take a value and wrap it in `{:ok, value}`
2. `error()`: take a value and wrap it in `{:error, value}`
3. `id()`: function that returns the value it's given
4. `tuple_wrap()`: macro that runs whatever you give it and returns {:error, ???} if it raises, otherwise {:ok, value}
5. `monad()` or something, maybe using that one safe operator, what's it?
	- Take a function and a maybe value (status tuple)
	- If it's an error tuple, pass it through
	- If it's an ok tuple, run the value through the function, which presumably returns another tuple
