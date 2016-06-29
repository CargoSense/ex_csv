defmodule ExCsv.Table do

  defstruct headings: [], body: [], row_struct: nil, row_mapping: nil

  defimpl Enumerable, for: __MODULE__ do
    def count(%ExCsv.Table{body: body}), do: body |> length
    def member?(%ExCsv.Table{}, _), do: {:error, __MODULE__}

    def reduce(_,     {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(%ExCsv.Table{} = table,  {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(table, &1, fun)}
    end
    def reduce(%ExCsv.Table{body: []},    {:cont, acc}, _fun), do: {:done, acc}
    def reduce(%ExCsv.Table{body: [h|t], headings: []} = table, {:cont, acc}, fun) do
      value = h |> construct(table)
      reduce(%{ table | body: t }, fun.(value, acc), fun)
    end
    def reduce(%ExCsv.Table{body: [h|t], headings: headings} = table, {:cont, acc}, fun) do
      value = Enum.zip(headings, h) |> Enum.into(%{}) |> construct(table)
      reduce(%{ table | body: t }, fun.(value, acc), fun)
    end

    defp construct(row, %{row_struct: nil}), do: row
    defp construct(row, %{row_struct: row_struct, row_mapping: nil }) when is_map(row) do
      base = struct(row_struct)
      add = Enum.map row, fn {k, v} ->
        {k |> String.to_existing_atom, v}
      end
      struct(base, add)
    end
    defp construct(row, %{row_struct: row_struct, row_mapping: row_mapping }) when is_map(row) and is_map(row_mapping) do
      base = struct(row_struct)
      add = Enum.reduce row_mapping, [], fn ({from, to}, acc) ->
        from = from |> to_string
        if row |> Map.has_key?(from) do
          acc ++ [{to, row[from]}]
        else
          acc
        end
      end
      struct(base, add)
    end
    defp construct(row, %{row_struct: row_struct, row_mapping: row_mapping}) when is_list(row) and is_list(row_mapping) do
      base = struct(row_struct)
      add = Enum.zip(row_mapping, row |> Enum.take(row_mapping |> length))
      struct(base, add)
    end

  end

end
