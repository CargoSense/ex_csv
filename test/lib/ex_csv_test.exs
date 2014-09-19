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

  test ".headings when not requested" do
    {:ok, table} = ExCsv.parse("a,b,c")
    assert table |> ExCsv.headings == []
  end

  test "without headings" do
    {:ok, table} = ExCsv.parse("a,b,c")
    assert table |> Enum.to_list == [["a", "b", "c"]]
  end

  test "with headings" do
    {:ok, table} = ExCsv.parse("from,to,cc\na,b,c", headings: true)
    assert table |> Enum.to_list == [%{"from" => "a", "to" => "b", "cc" => "c"}]
  end

  test "with headings, post parse" do
    {:ok, table} = ExCsv.parse("from,to,cc\na,b,c")
    assert table |> ExCsv.with_headings |> Enum.to_list == [%{"from" => "a", "to" => "b", "cc" => "c"}]
  end

  test "with headings, post parse and provided" do
    {:ok, table} = ExCsv.parse("a,b,c")
    assert table |> ExCsv.with_headings(~w(From To CC)) |> Enum.to_list == [%{"From" => "a", "To" => "b", "CC" => "c"}]
  end

  test "with headings, then removing them" do
    {:ok, table} = ExCsv.parse("from,to,cc\na,b,c", headings: true)
    assert table |> ExCsv.without_headings |> Enum.to_list == [~w"a b c"]
  end

  test ".headings when requested" do
    {:ok, table} = ExCsv.parse("a,b,c", headings: true)
    assert table |> ExCsv.headings == ["a", "b", "c"]
  end

  test "table with headings piping to ExCsv.as" do
    {:ok, table} = ExCsv.parse("cat,dog,bird\na,b,c\nd,e,f", headings: true)
    assert table |> ExCsv.as(EasyRow) |> Enum.to_list == [%EasyRow{cat: "a", dog: "b", bird: "c"},
                                                           %EasyRow{cat: "d", dog: "e", bird: "f"}]
  end

  test "table with headings piping to ExCsv.as with a string mapping" do
    {:ok, table} = ExCsv.parse("field1,field2,field3\na,b,c\nd,e,f", headings: true)
    mapping = %{"field1" => :dog, "field2" => :cat, "field3" => :bird}
    assert table |> ExCsv.as(EasyRow, mapping) |> Enum.to_list == [%EasyRow{dog: "a", cat: "b", bird: "c"},
                                                                   %EasyRow{dog: "d", cat: "e", bird: "f"}]
  end

  test "table with headings piping to ExCsv.as with a symbol mapping" do
    {:ok, table} = ExCsv.parse("field1,field2,field3\na,b,c\nd,e,f", headings: true)
    mapping = %{field1: :dog, field2: :cat, field3: :bird}
    assert table |> ExCsv.as(EasyRow, mapping) |> Enum.to_list == [%EasyRow{dog: "a", cat: "b", bird: "c"},
                                                                   %EasyRow{dog: "d", cat: "e", bird: "f"}]
  end

  test "table without headings and without a mapping list, piping to ExCsv.as" do
    {:ok, table} = ExCsv.parse("a,b,c\nd,e,f")
    assert_raise ArgumentError, fn ->
      assert table |> ExCsv.as(EasyRow)
    end
  end

  test "table without headings and with a mapping list of the same size, piping to ExCsv.as" do
    {:ok, table} = ExCsv.parse("a,b,c\nd,e,f")
    assert table |> ExCsv.as(EasyRow, [:bird, :cat, :dog]) |> Enum.to_list == [%EasyRow{bird: "a", cat: "b", dog: "c"},
                                                                                %EasyRow{bird: "d", cat: "e", dog: "f"}]
  end

  test "table without headings and with a mapping list of a smaller size, piping to ExCsv.as" do
    {:ok, table} = ExCsv.parse("a,b,c\nd,e,f")
    assert table |> ExCsv.as(EasyRow, [:bird, :cat]) |> Enum.to_list == [%EasyRow{bird: "a", cat: "b", dog: nil},
                                                                          %EasyRow{bird: "d", cat: "e", dog: nil}]
  end

end
