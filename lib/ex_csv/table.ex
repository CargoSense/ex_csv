defmodule ExCsv.Table do
  defstruct headings: [], body: [], row_struct: nil

  defimpl Enumerable, for: __MODULE__ do
    def count(%ExCsv.Table{body: body}), do: body |> length
    def member?(%ExCsv.Table{body: body}, value), do: {:error, __MODULE__}

    def reduce(_,     {:halt, acc}, _fun), do: {:halted, acc}
    def reduce(%ExCsv.Table{body: list} = table,  {:suspend, acc}, fun) do
      {:suspended, acc, &reduce(table, &1, fun)}
    end
    def reduce(%ExCsv.Table{body: []},    {:cont, acc}, _fun), do: {:done, acc}
    def reduce(%ExCsv.Table{body: [h|t], headings: []} = table, {:cont, acc}, fun) do
      reduce(%{ table | body: t }, fun.(h, acc), fun)
    end
    def reduce(%ExCsv.Table{body: [h|t], headings: headings} = table, {:cont, acc}, fun) do
      value = Enum.zip(headings, h) |> Enum.into(%{}) |> construct(table.row_struct)
      reduce(%{ table | body: t }, fun.(value, acc), fun)
    end

    defp construct(row, nil), do: row
    defp construct(row, row_struct) do
      base = struct(row_struct)
      add = Enum.map row, fn {k, v} ->
        {k |> String.to_existing_atom, v}
      end
      struct(base, add)
    end

  end

end
