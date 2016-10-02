import Redex.Client

defmodule Redex.ClientTest do
  use ExUnit.Case
  doctest Redex.Client

  setup_all do
    {:ok, pid} = Redex.Client.start_link
    [pid: pid]
  end

  test "should set and get a simple key", context do
    assert command(context[:pid], "set testkey0 testvalue0") ==
      {:str, "OK"}
    assert command(context[:pid], "get testkey0") ==
      {:bstr, "testvalue0"}
    assert command(context[:pid], "del testkey0") ==
      {:int, 1}
  end

  test "should set and get a key with an integral value", context do
    assert command(context[:pid], "set testkey0 10") ==
      {:str, "OK"}
    assert command(context[:pid], "get testkey0") ==
      {:bstr, "10"}
    assert command(context[:pid], "incr testkey0") ==
      {:int, 11}
    assert command(context[:pid], "del testkey0") ==
      {:int, 1}
  end
end

