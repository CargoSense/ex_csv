defmodule ExCsv.Parser do
  defstruct delimiter: 44, newline: 10, quote: 34, quoting: false, eat_next_quote: true

  def parse(text) do
    parse(text, %ExCsv.Parser{})
  end
  def parse(iodata, config) when is_list(iodata) do
    iodata |> IO.iodata_to_binary |> parse(config)
  end
  def parse(string, config) when is_binary(string) do
    {result, state} = string |> skip_whitespace |> build([[]], config)
    if state.quoting do
      {:error, "quote meets end of file"}
    else
      {:ok, result |> Enum.reverse |> Enum.map &(Enum.reverse(&1))}
    end
  end

  # DELIMITER
  # At the beginning of a row
  defp build(<<char>> <> rest, [[] | previous_rows], %{delimiter: char, quoting: false} = config) do
    current_row = [new_field, new_field]
    rows = [current_row | previous_rows]
    rest |> skip_whitespace |> build(rows, config)
  end
  # After the beginning of a row
  defp build(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{delimiter: char, quoting: false} = config) do
    current_row = [new_field | [current_field |> String.rstrip | previous_fields]]
    rows = [current_row | previous_rows]
    rest |> skip_whitespace |> build(rows, config)
  end

  # QUOTE
  # Start quote at the beginning of a field (don't retain this quote pair)
  defp build(<<char>> <> rest, [["" | _previous_fields] | _previous_rows] = rows, %{quote: char, quoting: false} = config) do
    rest |> build(rows, %{ config | quoting: true, eat_next_quote: true })
  end
  # Start quote in the middle of a field (retain this quote pair)
  defp build(<<char>> <> rest,  [[current_field | previous_fields] | previous_rows], %{quote: char, quoting: false} = config) do
    current_row = [current_field <> <<char::utf8>> | previous_fields]
    rows = [current_row | previous_rows]
    rest |> build(rows, %{ config | quoting: true, eat_next_quote: false })
  end
  # End quote and don't retain the quote character (full-field quoting)
  defp build(<<char>> <> rest, rows, %{quote: char, quoting: true, eat_next_quote: true} = config) do
    rest |> skip_whitespace |> build(rows, %{ config | quoting: false })
  end
  # End quote and retain the quote character (partial field quoting)
  defp build(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{quote: char, quoting: true, eat_next_quote: false} = config) do
    current_row = [current_field <> <<char::utf8>> | previous_fields]
    rows = [current_row | previous_rows]
    rest |> build(rows, %{ config | quoting: false })
  end

  # NEWLINE
  defp build(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], %{newline: char} = config) do
    current_row = [current_field |> String.rstrip | previous_fields]
    rows = [new_row | [current_row | previous_rows]]
    rest |> skip_whitespace |> build(rows, config)
  end

  # NORMAL CHARACTER
  # Starting the first field in the current row
  defp build(<<char>> <> rest, [[] | previous_rows], config) do
    current_row = [<<char::utf8>>]
    rows = [current_row | previous_rows]
    rest |> build(rows, config)
  end
  # Adding to the last field in the current row
  defp build(<<char>> <> rest, [[current_field | previous_fields] | previous_rows], config) do
    current_row = [current_field <> <<char::utf8>> | previous_fields]
    rows = [current_row | previous_rows]
    rest |> build(rows, config)
  end

  # EOF
  defp build("", rows, config), do: {rows, config}

  defp skip_whitespace(<<char>> <> rest) when char in '\s\r' do
    skip_whitespace(rest)
  end
  defp skip_whitespace(string), do: string

  defp new_field, do: ""
  defp new_row, do: []

end
