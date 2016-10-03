defmodule Redex.Client.Main do
  @prompt_string "REDEX > "

  def main(_args) do
    {:ok, pid} = Redex.Client.start_link()
    prompt(pid)
  end

  defp prompt(pid) do
    cmd = IO.gets(@prompt_string)
    case cmd do
      :eof ->
        quit()
      "exit\n" ->
        quit()
      "quit\n" ->
        quit()
      _ ->
        {_, resp} = Redex.Client.execute(pid, cmd |> String.trim)
        IO.puts(resp)
        prompt(pid)
    end
  end

  defp quit() do
    IO.puts("Goodbye!")
  end
end

