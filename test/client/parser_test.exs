import Redex.Client.Parser

defmodule Redex.Client.ParserTest do
  use ExUnit.Case
  doctest Redex.Client.Parser

  test "should parse a command with an integer" do
    assert parse_cmd("set count 1") == ["set", "count", 1]
  end

  test "should parse a command with a double quoted string" do
    assert parse_cmd("set name \"bob\"") == ["set", "name", "bob"]
  end

  test "should parse a command with a double quote literal" do
    assert parse_cmd(~s(set quote "\"hello\"")) == ["set", "quote", "\"hello\""]
  end

  test "should parse a command with a single quoted string" do
    assert parse_cmd("set name 'bob'") == ["set", "name", "bob"]
  end

  test "should parse a command with a single quote literal" do
    assert parse_cmd(~s(set quote '\'hello\'')) == ["set", "quote", "'hello'"]
  end
end
