defmodule ExCsv do

  defdelegate [parse(text), parse(text, settings)], to: ExCsv.Parser

end
