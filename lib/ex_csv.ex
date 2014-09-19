defmodule ExCsv do

  defdelegate [parse(text), parse(text, settings)], to: ExCsv.Parser

  def headings(%ExCsv.Table{headings: headings}), do: headings
  def body(%ExCsv.Table{body: body}), do: body

  def row(%ExCsv.Table{} = table, row_struct) do
    %{ table | row_struct: row_struct }
  end

end
