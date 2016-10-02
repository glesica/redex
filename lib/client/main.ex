defmodule Redex.Client.Main do
  def main(_args) do
    {:ok, pid} = Redex.Client.start_link()
    prompt(pid)
  end

  defp prompt(pid) do
    cmd = IO.gets("redex >") |> String.trim
    {_, resp} = Redex.Client.command(pid, cmd)
    IO.puts(resp)
    prompt(pid)
  end
end

