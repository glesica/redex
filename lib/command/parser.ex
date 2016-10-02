defmodule Redex.Command.Parser do
  @doc """
  Parse a command into tagged tuples that can be converted to RESP.
  """
  def parse(cmd), do: {:array, parse(cmd, [])}

  defp parse("", parts), do: parts
  defp parse(<< char::binary - size(1), tail::binary >> = cmd, parts) do
    case char do
      " " ->
        parse(tail, parts)
      "\t" ->
        parse(tail, parts)
      "\"" ->
        {part, newcmd} = consume_str(tail, "", "\"")
        parse(newcmd, parts ++ [part])
      "'" ->
        {part, newcmd} = consume_str(tail, "", "'")
        parse(newcmd, parts ++ [part])
      _ ->
        cond do
          String.match?(char, ~r"\d") ->
            {part, newcmd} = consume_int(cmd, "")
            parse(newcmd, parts ++ [part])
          true ->
            {part, newcmd} = consume_part(cmd, "")
            parse(newcmd, parts ++ [part])
        end
    end
  end

  defp consume_part(cmd, part) do
    case cmd do
      "" ->
        {{:bstr, part}, ""}
      << " ", tail::binary >> ->
        {{:bstr, part}, tail}
      << char::binary - size(1), tail::binary >> ->
        consume_part(tail, part <> char)
    end
  end

  defp consume_str(cmd, part, delim) do
    case cmd do
      ^delim ->
        {{:bstr, part}, ""}
      << ^delim, tail::binary >> ->
        {{:bstr, part}, tail}
      << "\\\\", tail::binary >> ->
        consume_str(tail, part <> "\\", delim)
      << "\\", ^delim, tail::binary >> ->
        consume_str(tail, part <> delim, delim)
      << char::binary - size(1), tail::binary >> ->
        consume_str(tail, part <> char, delim)
    end
  end

  defp consume_int(cmd, part) do
    case cmd do
      "" ->
        {{:int, String.to_integer(part)}, ""}
      << " ", tail::binary >> ->
        {{:int, String.to_integer(part)}, tail}
      << char::binary - size(1), tail::binary >> ->
        consume_int(tail, part <> char)
    end
  end
end

