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
    assert parse("+OK\r\n") == {:simple_string, "OK"}
  end

  test "should parse simple strings with spaces" do
    assert parse("+OK again\r\n") == {:simple_string, "OK again"}
  end

  test "should parse errors" do
    assert parse("-Error\r\n") == {:error, "Error"}
  end

  test "should parse multi-word errors" do
    assert parse("-Error again\r\n") == {:error, "Error again"}
  end

  test "should parse integers" do
    assert parse(":100\r\n") == {:integer, 100}
  end

  test "should parse negative integers" do
    assert parse(":-100\r\n") == {:integer, -100}
  end

  test "should parse zero integers" do
    assert parse(":0\r\n") == {:integer, 0}
  end

  test "should parse bulk strings" do
    assert parse("$5\r\nhello\r\n") == {:bulk_string, "hello"}
  end

  test "should parse an empty bulk string" do
    assert parse("$0\r\n\r\n") == {:bulk_string, ""}
  end

  test "should parse the null bulk string" do
    assert parse("$-1\r\n") == {:bulk_string, :null}
  end

  test "should return :error on bulk string length mismatch" do
    assert parse("$1\r\nab\r\n") == :error
    assert parse("$2\r\na\r\n") == :error
  end
end

