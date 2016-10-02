defmodule Redex.RESP.Parser do
  @doc """
  Parse the given RESP string into tagged tuples of native Elixir
  data structures.
  """
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

  # Consume some number of characters from the input and
  # return them as a string. The string returned may
  # contain one or more CRLFs.
  defp consume_bstr(data, n), do: consume_bstr(data, n, "")
  defp consume_bstr(<< "\r\n", new_data::binary >>, 0, bstr_chars) do
    {bstr_chars, new_data}
  end
  defp consume_bstr(<< next_char::binary - size(1), new_data::binary >>, n, bstr_chars) do
    consume_bstr(new_data, n - 1, bstr_chars <> next_char)
  end
  defp consume_bstr("", _, bstr_chars) do
    {:error, {:eof, bstr_chars}, ""}
  end

  # Consume characters until the next CRLF and return them,
  # interpreted as an integer.
  defp consume_int(data), do: consume_int(data, "")
  defp consume_int(<< "\r\n", new_data::binary >>, int_chars) do
    case Integer.parse(int_chars) do
      {parsed_int, ""} ->
        {parsed_int, new_data}
      :error ->
        {:error, {:invalid_int, int_chars}, new_data}
    end
  end
  defp consume_int(<< next_char::binary - size(1), new_data::binary >>, int_chars) do
    consume_int(new_data, int_chars <> next_char)
  end
  defp consume_int("", int_chars), do: {:error, {:eof, int_chars}, ""}

  # Consume a string from the input, reading up to the
  # next CRLF. The string returned will never include a
  # CRLF.
  defp consume_str(data), do: consume_str(data, "")
  defp consume_str(<< "\r\n", new_data::binary >>, str_chars) do
    {str_chars, new_data}
  end
  defp consume_str(<< next_char::binary - size(1), new_data::binary >>, str_chars) do
      consume_str(new_data, str_chars <> next_char)
  end
  defp consume_str("", str_chars), do: {:error, {:eof, str_chars}, ""}

  # Simple String
  defp parse_term(<< "+", new_data::binary >>) do
    case consume_str(new_data) do
      {str, new_data} when is_binary(str) ->
        {{:str, str}, new_data}
      {:error, {:eof, _}, _} ->
        :error
    end
  end

  # Error
  defp parse_term(<< "-", new_data::binary >>) do
    case consume_str(new_data) do
      {err, new_data} when is_binary(err) ->
        {{:err, err}, new_data}
      {:error, {:eof, _}, _} ->
        :error
    end
  end

  # Integer
  defp parse_term(<< ":", new_data::binary >>) do
    case consume_int(new_data) do
      {int, new_data} when is_integer(int) ->
        {{:int, int}, new_data}
      {:error, {:eof, _}, _} ->
        :error
      {:error, {:invalid_int, _}, _} ->
        :error
    end
  end

  # Bulk String
  defp parse_term(<< "$", new_data::binary >>) do
    case consume_int(new_data) do
      {-1, new_data} ->
        {{:bstr, :null}, new_data}
      {bstr_len, new_data} when is_integer(bstr_len) ->
        case consume_bstr(new_data, bstr_len) do
          {bstr, new_data} when is_binary(bstr) ->
            {{:bstr, bstr}, new_data}
          {:error, {:eof, _}, _} ->
            :error
        end
      {:error, {:eof, _}, _} ->
        :error
      {:error, {:invalid_int, _}, _} ->
        :error
    end
  end

  # Array
  defp parse_term(<< "*", new_data::binary >>) do
    case consume_int(new_data) do
      {-1, ""} ->
        {{:array, :null}, ""}
      {array_len, new_data} when is_integer(array_len) ->
        parse_array(new_data, array_len, [])
      {:error, {:eof, _}, _} ->
        :error
      {:error, {:invalid_int, _}, _} ->
        :error
    end
  end

  defp parse_term(_), do: :error

  defp parse_array(data, 0, array_els), do: {{:array, array_els}, data}
  defp parse_array("", _, _), do: :error
  defp parse_array(data, array_len, array_els) do
    case parse_term(data) do
      {array_el, new_data} ->
        parse_array(new_data, array_len - 1, array_els ++ [array_el])
      :error ->
        :error
    end
  end
end

