defmodule ExCsv.ParserTest do
  use ExUnit.Case

  test "one simple line" do
    assert ExCsv.Parser.parse(~s<a,b,c>) |> body == [["a", "b", "c"]]
  end
  test "one simple line with a space in a field" do
    assert ExCsv.Parser.parse(~s<a,ba t,c>) |> body == [["a", "ba t", "c"]]
  end
  test "one simple line with a quoted field containing the delimiter" do
    assert ExCsv.Parser.parse(~s<a,"ba,t",c>) |> body == [["a", "ba,t", "c"]]
  end
  test "one simple line with a quoted field containing the delimiter followed by whitespace" do
    assert ExCsv.Parser.parse(~s<a,"ba,t" ,c>) |> body == [["a", "ba,t", "c"]]
  end
  test "one simple line with a quoted portion of a field containing the delimiter" do
    assert ExCsv.Parser.parse(~s<a,he said "ok, there",c>) |> body == [["a", ~s<he said "ok, there">, "c"]]
  end
  test "one simple line with a quoted field that is not finished" do
    assert {:error, _} = ExCsv.Parser.parse(~s<a,"ba,t,c>)
  end
  test "one simple line that starts with a delimiter" do
    assert ExCsv.Parser.parse(~s<,a,b,c>) |> body == [["", "a", "b", "c"]]
  end
  test "one simple line that ends with a delimiter" do
    assert ExCsv.Parser.parse(~s<a,b,c,>) |> body == [["a", "b", "c", ""]]
  end
  test "one simple line with post-delimiter whitespace" do
    assert ExCsv.Parser.parse(~s<a,b, c>) |> body == [["a", "b", "c"]]
  end
  test "one simple line with pre-delimiter whitespace" do
    assert ExCsv.Parser.parse(~s<a,b ,c>) |> body == [["a", "b", "c"]]
  end

  test "two simple lines" do
    assert ExCsv.Parser.parse(~s<a,b,c\nd,e,f>) |> body == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with pre-newline whitespace" do
    assert ExCsv.Parser.parse(~s<a,b,c \nd,e,f>) |> body == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with post-newline whitespace" do
    assert ExCsv.Parser.parse(~s<a,b,c\n d,e,f>) |> body == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with second starting with a delimiter" do
    assert ExCsv.Parser.parse(~s<a,b,c\n,e,f>) |> body == [["a", "b", "c"], ["", "e", "f"]]
  end

  defp body({:ok, %{body: body}}), do: body

end
