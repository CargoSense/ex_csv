defmodule ExCsv.Parser do
  defstruct delimiter: 44, newline: 10, quote: 34, empty: ""

  def parse(text) do
    parse(text, %ExCsv.Parser{})
  end
  def parse(iodata, settings) when is_list(iodata) do
    IO.iodata_to_binary(iodata) |> parse(settings)
  end
  def parse(string, settings) when is_binary(string) do
    value(skip_whitespace(string), [[""]], settings)
    |> Enum.reverse |> Enum.map &(Enum.reverse(&1))
  end

  # Delimiter at the beginning of a line
  defp value(<<char>> <> rest, [[] | previous], %{delimiter: char} = settings) do
    value(skip_whitespace(rest), [[settings.empty, settings.empty] | previous], settings)
  end
  # Delimiter after the beginning of a line
  defp value(<<char>> <> rest, [[phrase | phrases] | previous], %{delimiter: char} = settings) do
    value(skip_whitespace(rest), [[settings.empty | [phrase |> String.rstrip | phrases]] | previous], settings)
  end

  # Newline
  defp value(<<char>> <> rest, [[phrase | phrases] | previous], %{newline: char} = settings) do
    value(skip_whitespace(rest), [[] | [[ phrase |> String.rstrip | phrases] | previous]], settings)
  end

  # First phrase in a line
  defp value(<<char>> <> rest, [[] | previous], settings) do
    value(rest, [[[char] |> to_string] | previous], settings)
  end
  # Another phrase in a line
  defp value(<<char>> <> rest, [[phrase | phrases] | previous], settings) do
    value(rest, [[phrase <> ([char] |> to_string) | phrases] | previous], settings)
  end
  defp value("", lines, settings), do: lines

  defp skip_whitespace(<<char>> <> rest) when char in '\s\r' do
    skip_whitespace(rest)
  end
  defp skip_whitespace(string), do: string

end
