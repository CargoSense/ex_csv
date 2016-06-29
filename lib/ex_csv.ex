defmodule ExCsv do

  defdelegate parse(text), to: ExCsv.Parser
  defdelegate parse(text, settings), to: ExCsv.Parser
  defdelegate parse!(text), to: ExCsv.Parser
  defdelegate parse!(text, settings), to: ExCsv.Parser

  def headings(%{headings: headings}), do: headings
  def body(%{body: body}), do: body

  def as(%{headings: []}, _row_struct) do
    raise ArgumentError, "Must use ExCsv.row/3 and provide a list of keys to use for a table without headings"
  end
  def as(table, row_struct) do
    %{ table | row_struct: row_struct }
  end

  def as(table, row_struct, row_mapping) do
    %{ table | row_struct: row_struct, row_mapping: row_mapping }
  end

  def with_headings(table, headings), do: %{ table | headings: headings }
  def with_headings(%{body: [first | rest]} = table) do
    %{ table | body: rest, headings: first }
  end

  def without_headings(table), do: %{ table | headings: [] }
end
