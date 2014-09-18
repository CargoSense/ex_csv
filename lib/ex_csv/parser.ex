defmodule ExCsv.Parser do
  defstruct delimiter: 44, newline: 10, quote: 34

  def parse(text) do
    parse(text, %ExCsv.Parser{})
  end
  def parse(iodata, settings) when is_list(iodata) do
    iodata |> IO.iodata_to_binary |> parse(settings)
  end
  def parse(string, settings) when is_binary(string) do
    read(skip_whitespace(string), [[]], settings)
    |> Enum.reverse |> Enum.map &(Enum.reverse(&1))
  end

  # Delimiter at the beginning of a row
  defp read(<<char>> <> rest, [[] | previous_rows], %{delimiter: char} = settings) do
    rows = [["", ""] | previous_rows]
    rest |> skip_whitespace |> read(rows, settings)
  end
  # Delimiter after the beginning of a row
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{delimiter: char} = settings) do
    rows = [["" | [current_field |> String.rstrip | previous_fields]] | previous_rows]
    rest |> skip_whitespace |> read(rows, settings)
  end

  # Newline
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{newline: char} = settings) do
    rows = [[] | [[current_field |> String.rstrip | previous_fields] | previous_rows]]
    rest |> skip_whitespace |> read(rows, settings)
  end

  # Starting the first field in the current row
  defp read(<<char>> <> rest, [[] | previous_rows], settings) do
    rows = [[<<char::utf8>>] | previous_rows]
    rest |> read(rows, settings)
  end
  # Adding to the last field in the current row
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], settings) do
    rows = [[current_field <> <<char::utf8>> | previous_fields] | previous_rows]
    rest |> read(rows, settings)
  end

  # All done
  defp read("", rows, settings), do: rows

  defp skip_whitespace(<<char>> <> rest) when char in '\s\r' do
    skip_whitespace(rest)
  end
  defp skip_whitespace(string), do: string

end
