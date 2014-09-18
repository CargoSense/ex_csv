defmodule ExCsv.Parser do
  defstruct delimiter: 44, newline: 10, quote: 34

  def parse(text) do
    parse(text, %ExCsv.Parser{})
  end
  def parse(iodata, settings) when is_list(iodata) do
    IO.iodata_to_binary(iodata) |> parse(settings)
  end
  def parse(string, settings) when is_binary(string) do
    read(skip_whitespace(string), [[]], settings)
    |> Enum.reverse |> Enum.map &(Enum.reverse(&1))
  end

  # Delimiter at the beginning of a line
  defp read(<<char>> <> rest, [[] | previous_lines], %{delimiter: char} = settings) do
    read(skip_whitespace(rest), [["", ""] | previous_lines], settings)
  end
  # Delimiter after the beginning of a line
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_lines], %{delimiter: char} = settings) do
    read(skip_whitespace(rest), [["" | [current_field |> String.rstrip | previous_fields]] | previous_lines], settings)
  end

  # Newline
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_lines], %{newline: char} = settings) do
    read(skip_whitespace(rest), [[] | [[current_field |> String.rstrip | previous_fields] | previous_lines]], settings)
  end

  # Starting the first field in the current line
  defp read(<<char>> <> rest, [[] | previous_lines], settings) do
    read(rest, [[[char] |> IO.iodata_to_binary] | previous_lines], settings)
  end
  # Adding to the last field in the current line
  defp read(<<char>> <> rest, [[current_field | previous_fields] | previous_lines], settings) do
    read(rest, [[current_field <> ([char] |> IO.iodata_to_binary) | previous_fields] | previous_lines], settings)
  end

  # All done
  defp read("", lines, settings), do: lines

  defp skip_whitespace(<<char>> <> rest) when char in '\s\r' do
    skip_whitespace(rest)
  end
  defp skip_whitespace(string), do: string

end
