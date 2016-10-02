import Redex.Command.Parser

defmodule Redex.Command.ParserTest do
  use ExUnit.Case
  doctest Redex.Command.Parser

  test "should parse a command with an integer" do
    assert parse("set count 1") ==
      {:array, [{:bstr, "set"}, {:bstr, "count"}, {:int, 1}]}
  end

  test "should parse a command with a double quoted string" do
    assert parse("set name \"bob\"") ==
      {:array, [{:bstr, "set"}, {:bstr, "name"}, {:bstr, "bob"}]}
  end

  test "should parse a command with a double quote literal" do
    assert parse(~s(set quote "\"hello\"")) ==
      {:array, [{:bstr, "set"}, {:bstr, "quote"}, {:bstr, "\"hello\""}]}
  end

  test "should parse a command with a single quoted string" do
    assert parse("set name 'bob'") ==
      {:array, [{:bstr, "set"}, {:bstr, "name"}, {:bstr, "bob"}]}
  end

  test "should parse a command with a single quote literal" do
    assert parse(~s(set quote '\'hello\'')) ==
      {:array, [{:bstr, "set"}, {:bstr, "quote"}, {:bstr, "'hello'"}]}
  end
end

