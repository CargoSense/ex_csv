defmodule ExCsvTest do
  use ExUnit.Case

  test "parse delegate without custom setting" do
    assert ExCsv.parse("a,b,c") == {:ok, [~w(a b c)]}
  end

  test "parse delegate with a custom setting" do
    assert ExCsv.parse("a;b;c", %ExCsv.Parser{delimiter: ';' |> hd}) == {:ok, [~w(a b c)]}
  end

end
