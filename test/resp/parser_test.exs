import Redex.RESP.Parser

defmodule Redex.RESP.ParserTest do
  use ExUnit.Case
  doctest Redex.RESP.Parser

  test "should return :error when line ending is missing" do
    assert parse("+OK") == :error
  end

  test "should return :error when prefix is missing" do
    assert parse("OK\r\n") == :error
  end

  test "should parse simple strings" do
    assert parse("+OK\r\n") == {:str, "OK"}
  end

  test "should parse simple strings with spaces" do
    assert parse("+OK again\r\n") == {:str, "OK again"}
  end

  test "should parse errors" do
    assert parse("-Error\r\n") == {:err, "Error"}
  end

  test "should parse multi-word errors" do
    assert parse("-Error again\r\n") == {:err, "Error again"}
  end

  test "should parse integers" do
    assert parse(":100\r\n") == {:int, 100}
  end

  test "should parse negative integers" do
    assert parse(":-100\r\n") == {:int, -100}
  end

  test "should parse the zero integer" do
    assert parse(":0\r\n") == {:int, 0}
  end

  test "should parse bulk strings" do
    assert parse("$5\r\nhello\r\n") == {:bstr, "hello"}
  end

  test "should parse an empty bulk string" do
    assert parse("$0\r\n\r\n") == {:bstr, ""}
  end

  test "should parse the null bulk string" do
    assert parse("$-1\r\n") == {:bstr, :null}
  end

  test "should return :error on bulk string length mismatch" do
    assert parse("$1\r\nab\r\n") == :error
    assert parse("$2\r\na\r\n") == :error
  end

  test "should parse an empty array" do
    assert parse("*0\r\n") == {:array, []}
  end

  test "should parse a null array" do
    assert parse("*-1\r\n") == {:array, :null}
  end

  test "should parse an array with homogeneous simple types" do
    assert parse("*2\r\n:1\r\n:2\r\n") == {:array, [{:int, 1}, {:int, 2}]}
  end

  test "should parse an array with mixed simple types" do
    assert parse("*2\r\n+OK\r\n:1\r\n") == {:array, [{:str, "OK"}, {:int, 1}]}
  end

  test "should parse an array that includes bulk strings" do
    assert parse("*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n") == 
      {:array, [{:bstr, "foo"}, {:bstr, "bar"}]}
  end

  test "should parse an array of arrays" do
    assert parse("*2\r\n*2\r\n:1\r\n:2\r\n*2\r\n+foo\r\n-bar\r\n") ==
      {:array, [{:array, [{:int, 1}, {:int, 2}]},
        {:array, [{:str, "foo"}, {:err, "bar"}]}]}
  end

  test "should return :error on array length mismatch" do
    assert parse("*2\r\n+OK\r\n") == :error
  end

  test "should return :error on array on element parse error" do
    assert parse("*1\r\nOK\r\n") == :error
  end
end

