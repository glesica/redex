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
end

