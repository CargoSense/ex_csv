defmodule ExCsv.Parser do
  defstruct delimiter: 44, newline: 10, quote: 34

  def parse(text) do
    parse(text, %ExCsv.Parser{})
  end
  def parse(iodata, settings) when is_list(iodata) do
    iodata |> IO.iodata_to_binary |> parse(settings)
  end
  def parse(string, settings) when is_binary(string) do
    string |> skip_whitespace |> read([[]], settings)
           |> Enum.reverse |> Enum.map &(Enum.reverse(&1))
  end

  # DELIMITER
  # At the beginning of a row
  defp read(<<char>> <> rest, [[] | previous_rows], %{delimiter: char} = settings) do
    current_row = [new_field, new_field]
    rows = [current_row | previous_rows]
    rest |> skip_whitespace |> read(rows, settings)
  end
  # After the beginning of a row
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{delimiter: char} = settings) do
    current_row = [new_field | [current_field |> String.rstrip | previous_fields]]
    rows = [current_row | previous_rows]
    rest |> skip_whitespace |> read(rows, settings)
  end

  # NEWLINE
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{newline: char} = settings) do
    current_row = [current_field |> String.rstrip | previous_fields]
    rows = [new_row | [current_row | previous_rows]]
    rest |> skip_whitespace |> read(rows, settings)
  end

  # NORMAL CHARACTER
  # Starting the first field in the current row
  defp read(<<char>> <> rest, [[] | previous_rows], settings) do
    current_row = [<<char::utf8>>]
    rows = [current_row | previous_rows]
    rest |> read(rows, settings)
  end
  # Adding to the last field in the current row
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], settings) do
    current_row = [current_field <> <<char::utf8>> | previous_fields]
    rows = [current_row | previous_rows]
    rest |> read(rows, settings)
  end

  # EOF
  defp read("", rows, _settings), do: rows

  defp skip_whitespace(<<char>> <> rest) when char in '\s\r' do
    skip_whitespace(rest)
  end
  defp skip_whitespace(string), do: string

  defp new_field, do: ""
  defp new_row, do: []

end
