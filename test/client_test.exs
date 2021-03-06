import Redex.Client

defmodule Redex.ClientTest do
  use ExUnit.Case
  doctest Redex.Client

  setup_all do
    {:ok, pid} = Redex.Client.start_link
    [pid: pid]
  end

  @tag :skip
  test "should set and get a simple key", context do
    assert execute(context[:pid], "set testkey0 testvalue0") ==
      {:str, "OK"}
    assert execute(context[:pid], "get testkey0") ==
      {:bstr, "testvalue0"}
    assert execute(context[:pid], "del testkey0") ==
      {:int, 1}
  end

  @tag :skip
  test "should set and get a key with an integral value", context do
    assert execute(context[:pid], "set testkey0 10") ==
      {:str, "OK"}
    assert execute(context[:pid], "get testkey0") ==
      {:bstr, "10"}
    assert execute(context[:pid], "incr testkey0") ==
      {:int, 11}
    assert execute(context[:pid], "del testkey0") ==
      {:int, 1}
  end
end

