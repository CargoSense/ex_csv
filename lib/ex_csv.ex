defmodule ExCsv do

  defdelegate [parse(text), parse(text, settings)], to: ExCsv.Parser

  def headings(%ExCsv.Table{headings: headings}), do: headings
  def body(%ExCsv.Table{body: body}), do: body

  def as(%ExCsv.Table{headings: []}, _row_struct) do
    raise ArgumentError, "Must use ExCsv.row/3 and provide a list of keys to use for a table without headings"
  end
  def as(%ExCsv.Table{} = table, row_struct) do
    %{ table | row_struct: row_struct }
  end

  def as(%ExCsv.Table{} = table, row_struct, row_mapping) do
    %{ table | row_struct: row_struct, row_mapping: row_mapping }
  end

end
