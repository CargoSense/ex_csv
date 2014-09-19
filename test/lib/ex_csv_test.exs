defmodule ExCsvTest do
  use ExUnit.Case

  test "parse delegate without custom setting" do
    {:ok, %{body: [~w(a b c)]}} = ExCsv.parse("a,b,c")
  end

  test "parse delegate with a custom setting" do
    {:ok, %{body: [~w(a b c)]}} = ExCsv.parse("a;b;c", delimiter: ';')
  end

  test "headings when not requested" do
    {:ok, table} = ExCsv.parse("a,b,c")
    assert table |> ExCsv.headings == []
  end

  test "Enum.into without headings" do
    {:ok, table} = ExCsv.parse("a,b,c")
    assert table |> Enum.to_list == [["a", "b", "c"]]
  end

  test "headings when requested" do
    {:ok, table} = ExCsv.parse("a,b,c", headings: true)
    assert table |> ExCsv.headings == ["a", "b", "c"]
  end

  test "Enum.into with headings" do
    {:ok, table} = ExCsv.parse("cat,dog,bird\na,b,c\nd,e,f", headings: true)
    assert table |> Enum.to_list == [%{"cat" => "a", "dog" => "b", "bird" => "c"},%{"cat" => "d", "dog" => "e", "bird" => "f"}]
  end

end
