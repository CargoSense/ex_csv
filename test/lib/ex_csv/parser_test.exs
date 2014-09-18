defmodule ExCsv.ParserTest do
  use ExUnit.Case

  test "one simple line" do
    assert ExCsv.Parser.parse(~s<a,b,c>) == [["a", "b", "c"]]
  end
  test "one simple line with a space in a field" do
    assert ExCsv.Parser.parse(~s<a,ba t,c>) == [["a", "ba t", "c"]]
  end
  test "one simple line with a quoted field containing the delimiter" do
    assert ExCsv.Parser.parse(~s<a,"ba,t",c>) == [["a", "ba,t", "c"]]
  end
  test "one simple line that starts with a delimiter" do
    assert ExCsv.Parser.parse(~s<,a,b,c>) == [["", "a", "b", "c"]]
  end
  test "one simple line that ends with a delimiter" do
    assert ExCsv.Parser.parse(~s<a,b,c,>) == [["a", "b", "c", ""]]
  end
  test "one simple line with post-delimiter whitespace" do
    assert ExCsv.Parser.parse(~s<a,b, c>) == [["a", "b", "c"]]
  end
  test "one simple line with pre-delimiter whitespace" do
    assert ExCsv.Parser.parse(~s<a,b ,c>) == [["a", "b", "c"]]
  end

  test "two simple lines" do
    assert ExCsv.Parser.parse(~s<a,b,c\nd,e,f>) == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with pre-newline whitespace" do
    assert ExCsv.Parser.parse(~s<a,b,c \nd,e,f>) == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with post-newline whitespace" do
    assert ExCsv.Parser.parse(~s<a,b,c\n d,e,f>) == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with second starting with a delimiter" do
    assert ExCsv.Parser.parse(~s<a,b,c\n,e,f>) == [["a", "b", "c"], ["", "e", "f"]]
  end
end
