defmodule ExCsvTest do
  use ExUnit.Case

  defmodule EasyRow do
    @derive [Enumerable, Access]
    defstruct cat: nil, dog: nil, bird: nil
  end

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

  test "Enum.into with headings and :as" do
    {:ok, table} = ExCsv.parse("cat,dog,bird\na,b,c\nd,e,f", headings: true, as: EasyRow)
    assert table |> Enum.to_list == [%EasyRow{cat: "a", dog: "b", bird: "c"},
                                     %EasyRow{cat: "d", dog: "e", bird: "f"}]
  end

  test "Enum.into with headings piping to ExCsv.row" do
    {:ok, table} = ExCsv.parse("cat,dog,bird\na,b,c\nd,e,f", headings: true)
    assert table |> ExCsv.row(EasyRow) |> Enum.to_list == [%EasyRow{cat: "a", dog: "b", bird: "c"},
                                                           %EasyRow{cat: "d", dog: "e", bird: "f"}]
  end


end
