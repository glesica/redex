defmodule Redex.RESP.Parser do
  def parse([<< "+", d::binary >>, ""]), do: {:simple_string, d}
  def parse([<< "-", d::binary >>, ""]), do: {:error, d}
  def parse([<< ":", d::binary >>, ""]), do: {:integer, String.to_integer(d)}
  def parse([<< "$", l::binary >>, d, ""]) do
    case Integer.parse(l) do
      {len, ""} ->
        if len == String.length(d) do
          {:bulk_string, d}
        else
          :error
        end
      :error ->
        :error
    end
  end
  def parse([<< "$", l::binary >>, ""]) do
    case Integer.parse(l) do
      {len, ""} ->
        if len == -1 do
          {:bulk_string, :null}
        else
          :error
        end
      :error ->
        :error
    end
  end
  def parse(cmd) when is_list(cmd), do: :error
  def parse(cmd), do: String.split(cmd, "\r\n") |> parse
end
