defmodule Redex.RESP.Parser do
  defp consume_bstr(d, l) when is_binary(d), do: consume_bstr(d, l, "")
  defp consume_bstr(<< "\r\n", t::binary >>, 0, s), do: {s, t}
  defp consume_bstr(<< c::binary - size(1), t::binary >>, l, s) do
    consume_bstr(t, l - 1, s <> c)
  end
  defp consume_bstr("", _, s), do: {:error_bstr, {:eof, s}, ""}

  defp consume_int(d) when is_binary(d), do: consume_int(d, "")
  defp consume_int(<< "\r\n", t::binary >>, s) do
    case Integer.parse(s) do
      {i, ""} ->
        {i, t}
      :error ->
        {:error_int, {:invalid_int, s}, t}
    end
  end
  defp consume_int(<< c::binary - size(1), t::binary >>, s) do
    consume_int(t, s <> c)
  end
  defp consume_int("", s), do: {:error_int, {:eof, s}, ""}

  defp consume_str(d) when is_binary(d), do: consume_str(d, "")
  defp consume_str(<< "\r\n", t::binary >>, s), do: {s, t}
  defp consume_str(<< c::binary - size(1), t::binary >>, s) do
      consume_str(t, s <> c)
  end
  defp consume_str("", s), do: {:error_str, {:eof, s}, ""}

  defp parse_term(<< "+", t::binary >>) do
    case consume_str(t) do
      {s, tt} when is_binary(s) ->
        {{:str, s}, tt}
      {:error_str, {:eof, _}, _} ->
        :error
    end
  end
  defp parse_term(<< "-", t::binary >>) do
    case consume_str(t) do
      {s, tt} when is_binary(s) ->
        {{:err, s}, tt}
      {:error_str, {:eof, _}, _} ->
        :error
    end
  end
  defp parse_term(<< ":", t::binary >>) do
    case consume_int(t) do
      {i, tt} when is_integer(i) ->
        {{:int, i}, tt}
      {:error_int, {:eof, _}, _} ->
        :error
      {:error_int, {:invalid_int, _}, _} ->
        :error
    end
  end
  defp parse_term(<< "$", t::binary >>) do
    case consume_int(t) do
      {-1, tt} ->
        {{:bstr, :null}, tt}
      {l, tt} when is_integer(l) ->
        case consume_bstr(tt, l) do
          {s, ttt} when is_binary(s) ->
            {{:bstr, s}, ttt}
          {:error_bstr, {:eof, _}, _} ->
            :error
        end
      {:error_int, {:eof, _}, _} ->
        :error
      {:error_int, {:invalid_int, _}, _} ->
        :error
    end
  end
  defp parse_term(<< "*", t::binary >>) do
    case consume_int(t) do
      {l, tt} when is_integer(l) ->
        parse_array(tt, l, [])
      {:error_int, {:eof, _}, _} ->
        :error
      {:error_int, {:invalid_int, _}, _} ->
        :error
    end
  end
  defp parse_term(_), do: :error

  defp parse_array(s, 0, terms), do: {{:array, terms}, s}
  defp parse_array("", _, _), do: :error
  defp parse_array(s, l, terms) do
    case parse_term(s) do
      {term, t} ->
        parse_array(t, l - 1, terms ++ [term])
      :error ->
        :error
    end
  end

  def parse(s) do
    case parse_term(s) do
      :error ->
        :error
      {term, ""} ->
        term
      {_, _} ->
        :error
    end
  end
end
