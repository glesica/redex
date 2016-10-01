defmodule Redex.Client.Parser do
  defp consume_part(cmd, part) do
    case cmd do
      "" ->
        {part, ""}
      << " ", tail::binary >> ->
        {part, tail}
      << char::binary - size(1), tail::binary >> ->
        consume_part(tail, part <> char)
    end
  end

  defp consume_str(cmd, part, delim) do
    case cmd do
      ^delim ->
        {part, ""}
      << ^delim, tail::binary >> ->
        {part, tail}
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
        {String.to_integer(part), ""}
      << " ", tail::binary >> ->
        {part, tail}
      << char::binary - size(1), tail::binary >> ->
        consume_int(tail, part <> char)
    end
  end

  defp parse_cmd("", parts), do: parts
  defp parse_cmd(<< char::binary - size(1), tail::binary >> = cmd, parts) do
    case char do
      " " ->
        parse_cmd(tail, parts)
      "\t" ->
        parse_cmd(tail, parts)
      "\"" ->
        {part, newcmd} = consume_str(tail, "", "\"")
        parse_cmd(newcmd, parts ++ [part])
      "'" ->
        {part, newcmd} = consume_str(tail, "", "'")
        parse_cmd(newcmd, parts ++ [part])
      _ ->
        cond do
          String.match?(char, ~r"\d") ->
            {part, newcmd} = consume_int(cmd, "")
            parse_cmd(newcmd, parts ++ [part])
          true ->
            {part, newcmd} = consume_part(cmd, "")
            parse_cmd(newcmd, parts ++ [part])
        end
    end
  end

  def parse_cmd(cmd), do: parse_cmd(cmd, [])
end
