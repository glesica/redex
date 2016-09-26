defmodule Redex.Client.Parser do
  defp parse_str(<< "\"", tail::binary >>), do: parse_str(tail, "")
  defp parse_str("\"", str), do: str
  defp parse_str(<< next::binary - size(1), tail::binary >>, str), do: parse_str(tail, str <> next)

  defp tokenize(cmd) when is_binary(cmd) do
    cmd
      |> String.split(~r/\W/)
  end
end
