import Redex.RESP.Composer

defmodule Redex.RESP.ComposerTest do
  use ExUnit.Case
  doctest Redex.RESP.Composer

  test "should compose simple strings" do
    assert compose({:str, "OK"}) == "+OK\r\n"
  end

  test "should compose simple strings with spaces" do
    assert compose({:str, "OK again"}) == "+OK again\r\n"
  end

  test "should compose errors" do
    assert compose({:err, "Error"}) == "-Error\r\n"
  end

  test "should compose multi-word errors" do
    assert compose({:err, "Error again"}) == "-Error again\r\n"
  end

  test "should compose integers" do
    assert compose({:int, 100}) == ":100\r\n"
  end

  test "should compose negative integers" do
    assert compose({:int, -100}) == ":-100\r\n"
  end

  test "should compose the zero integer" do
    assert compose({:int, 0}) == ":0\r\n"
  end

  test "should compose bulk strings" do
    assert compose({:bstr, "hello"}) == "$5\r\nhello\r\n"
  end

  test "should compose an empty bulk string" do
    assert compose({:bstr, ""}) == "$0\r\n\r\n"
  end

  test "should compose the null bulk string" do
    assert compose({:bstr, :null}) == "$-1\r\n"
  end

  test "should compose an empty array" do
    assert compose({:array, []}) == "*0\r\n"
  end

  test "should compose a null array" do
    assert compose({:array, :null}) == "*-1\r\n"
  end

  test "should compose an array with homogeneous simple types" do
    assert compose({:array, [{:int, 1}, {:int, 2}]}) == "*2\r\n:1\r\n:2\r\n"
  end

  test "should compose an array with mixed simple types" do
    assert compose({:array, [{:str, "OK"}, {:int, 1}]}) == "*2\r\n+OK\r\n:1\r\n"
  end

  test "should compose an array that includes bulk strings" do
    assert compose({:array, [{:bstr, "foo"}, {:bstr, "bar"}]}) ==
      "*2\r\n$3\r\nfoo\r\n$3\r\nbar\r\n"
  end

  test "should compose an array of arrays" do
      assert compose({:array, [{:array, [{:int, 1}, {:int, 2}]},
        {:array, [{:str, "foo"}, {:err, "bar"}]}]}) ==
          "*2\r\n*2\r\n:1\r\n:2\r\n*2\r\n+foo\r\n-bar\r\n"
  end
end

