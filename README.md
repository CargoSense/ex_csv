ExCsv
=====

Elixir CSV.

Note: Currently only supports parsing.

## Usage

### Parsing

Parsing a file gives you a `ExCsv.Table` struct:

```elixir
File.read!("foo/bar.csv") |> ExCsv.parse
# => %ExCsv.Table{...}
```

If your CSV has headings, you can let the parser know up front:

```elixir
table = File.read!("foo/bar.csv") |> ExCsv.parse(headings: true)
# => %ExCsv.Table{...}
table.headings
# => ["Person", "Current Age"]
```

Or you can use `ExCsv.with_headings/1` afterwards:

```elixir
table = File.read!("foo/bar.csv")
        |> ExCsv.parse
        |> ExCsv.with_headings
# => %ExCsv.Table{...}
table.headings
# => ["Person", "Current"]
```

You can also change the set or change headings by using
`ExCsv.headings/2`:

```elixir
table = File.read!("foo/bar.csv")
        |> ExCsv.parse
        |> ExCsv.with_headings(["name", "age"])
# => %ExCsv.Table{...}
table.headings
# => ["name", "age"]
```

If you need to parse a format that uses another delimiter character,
you can set it as an option (note the single quotes):

```elixir
table = File.read!("foo/bar.csv", delimiter: ';')
# => %ExCsv.Table{...}
```

Once you have a `ExCsv.Table`, you can use its `headings` and `body`
directly -- or you enumerate over the table.

## Enumerating

If your `ExCsv.Table` struct does not have headers, iterating over it
will result in a list for each row:

```elixir
table = File.read!("foo/bar.csv")
        |> ExCsv.parse
# => %ExCsv.Table{...}
for row <- table, do: IO.inspect(row)
# ["Jayson", 23]
# ["Jill", 34]
# ["Benson", 45]
```

If your table has headings, you'll get maps:

```elixir
table = File.read!("foo/bar.csv")
        |> ExCsv.parse
        |> ExCsv.with_headings([:name, :age])
# => %ExCsv.Table{...}
for row <- table, do: IO.inspect(row)
# %{name: "Jayson", age: 23}
# %{name: "Jill", age: 34}
# %{name: "Benson", age: 45}
```

You can build structs from the rows by using `ExCsv.as/1` (if the
headings match the struct attributes):

```elixir
table = File.read!("foo/bar.csv")
        |> ExCsv.parse
        |> ExCsv.with_headings([:name, :age])
        |> ExCsv.as(Person)
# => %ExCsv.Table{...}
for row <- table, do: IO.inspect(row)
# %Person{name: "Jayson", age: 23}
# %Person{name: "Jill", age: 34}
# %Person{name: "Benson", age: 45}
```

If the headings don't match the struct attributes, you can provide a
mapping (of CSV heading name to struct attribute name) with
`ExCsv.as/2`:

```elixir
table = File.read!("books.csv")
        |> ExCsv.parse(headings: true)
        |> ExCsv.as(Author, %{"name" => :title, "author" => :name})
# => %ExCsv.Table{...}
for row <- table, do: IO.inspect(row)
# %Author{name: "John Scalzi", title: "A War for Old Men"}
# %Author{name: "Margaret Atwood", title: "A Handmaid's Tale"}
```

## Contributing

Please fork and send pull requests (preferably from non-master
branches), including tests (`ExUnit.Case`).

Report bugs and request features via Issues; PRs are even better!

## License

The MIT License (MIT)

Copyright (c) 2014 CargoSense, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
