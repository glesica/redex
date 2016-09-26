defmodule Redex.RESP.Composer do
  def compose({:str, str}), do: "+#{str}\r\n"
  def compose({:err, err}), do: "-#{err}\r\n"
  def compose({:int, int}), do: ":#{int}\r\n"
  def compose({:bstr, :null}), do: "$-1\r\n"
  def compose({:bstr, bstr}), do: "$#{String.length(bstr)}\r\n#{bstr}\r\n"
  def compose({:array, :null}), do: "*-1\r\n"
  def compose({:array, array}) do
    array_len = length(array)
    terms_str = Enum.reduce(array, "", fn t, str -> str <> compose(t) end)
    "*#{array_len}\r\n#{terms_str}"
  end

  # TODO: This is extremely naive, improve it.
  def command(cmd) when is_binary(cmd) do
    cmd
      |> String.split(" ")
      |> Enum.map(&cmd_compose/1)
      |> Enum.reduce({:array, []}, fn b, {:array, l} -> {:array, l ++ [b]} end)
      |> compose
  end
  def command(cmd) when is_list(cmd), do: cmd |> cmd_compose |> compose

  defp cmd_compose(data) when is_binary(data), do: {:bstr, data}
  defp cmd_compose(data) when is_integer(data), do: {:int, data}
  defp cmd_compose(data) when is_list(data), do: {:array, data |> Enum.map(&cmd_compose/1)}
end
