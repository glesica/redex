import Redex.Client

defmodule Redex.ClientTest do
  use ExUnit.Case
  doctest Redex.Client

  setup_all do
    {:ok, pid} = Redex.Client.start_link
    [pid: pid]
  end

  test "should set a key", context do
    assert command(context[:pid], "set testkey0 testvalue0") ==
      {:str, "OK"}
  end

  test "should get a key's value", context do
    assert command(context[:pid], "get testkey0") ==
      {:bstr, "testvalue0"}
  end
end

