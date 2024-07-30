alias AdventOfCode.Y2015.LookSay

defmodule AdventOfCode.Y2015.LookSay do
  @spec look_say(binary(), %{binary() => binary()}) ::
          {binary(), %{binary() => binary()}}
  def look_say(input, memory \\ %{}) do
    if memory |> Map.has_key?(input) do
      {memory[input], memory}
    else
      n = input |> String.length()
      n_halves = n |> Bitwise.>>>(1)

      is_middle_dup =
        input
        |> String.at(n_halves) ==
          input
          |> String.at(n_halves - 1)

      if n_halves |> Bitwise.<<<(1) == n and !is_middle_dup do
        input
        |> String.split_at(n_halves)
        |> Tuple.to_list()
        |> Enum.map(&look_say(&1, memory))
        |> Enum.reduce({"", memory}, fn {str, map}, {acc_str, acc_map} ->
          {acc_str <> str, acc_map |> Map.merge(map)}
        end)
      else
        result =
          input
          |> String.graphemes()
          |> Enum.chunk_by(fn x -> x end)
          |> Enum.map(fn x ->
            "#{length(x)}" <> List.first(x)
          end)
          |> Enum.join()

        {result, memory |> Map.put_new(input, result)}
      end
    end
  end
end

1..50
|> Enum.reduce({"3113322113", %{}}, fn idx, {input, memory} ->
  acc = input |> LookSay.look_say(memory)
  {result, _} = acc

  "#{idx}: #{result |> String.length()}" |> IO.puts()

  acc
end)
