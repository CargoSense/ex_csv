defmodule ExCsv.ParserTest do
  use ExUnit.Case

 test "one simple line" do
   assert ExCsv.Parser.parse("a,b,c") == [["a", "b", "c"]]
 end
  test "one simple line that starts with a delimiter" do
    assert ExCsv.Parser.parse(",a,b,c") == [["", "a", "b", "c"]]
  end
  test "one simple line that ends with a delimiter" do
    assert ExCsv.Parser.parse("a,b,c,") == [["a", "b", "c", ""]]
  end
  test "one simple line with post-delimiter whitespace" do
    assert ExCsv.Parser.parse("a,b, c") == [["a", "b", "c"]]
  end
  test "one simple line with pre-delimiter whitespace" do
    assert ExCsv.Parser.parse("a,b ,c") == [["a", "b", "c"]]
  end

  test "two simple lines" do
    assert ExCsv.Parser.parse("a,b,c\nd,e,f") == [["a", "b", "c"], ["d", "e", "f"]]
  end
  test "two simple lines with second starting with a delimiter" do
    assert ExCsv.Parser.parse("a,b,c\n,e,f") == [["a", "b", "c"], ["", "e", "f"]]
  end
end
