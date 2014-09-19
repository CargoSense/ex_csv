defmodule ExCsv.Table do
  defstruct headings: [], body: []

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
      map = Enum.zip(headings, h) |> Enum.into(%{})
      reduce(%{ table | body: t }, fun.(map, acc), fun)
    end
  end

end
