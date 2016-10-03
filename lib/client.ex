import Redex.Command.Parser
import Redex.RESP.Composer

defmodule Redex.Client do
  use GenServer

  @initial_state %{socket: nil}

  def execute(pid, cmd) do
    GenServer.call(pid, {:cmd, cmd})
  end

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state)
  end

  def init(state) do
    opts = [:binary, active: false]
    {:ok, socket} = :gen_tcp.connect('localhost', 9876, opts)
    {:ok, %{state | socket: socket}}
  end

  def handle_call({:cmd, cmd}, _, %{socket: socket} = state) do
    :ok = :gen_tcp.send(socket, cmd |> parse |> compose)
    {:ok, msg} = :gen_tcp.recv(socket, 0)
    {:reply, Redex.RESP.Parser.parse(msg), state}
  end
end

