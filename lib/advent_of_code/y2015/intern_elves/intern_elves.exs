alias AdventOfCode.Y2015.InternElves

defmodule AdventOfCode.Y2015.InternElves do
  @spec isNiceA?(binary()) :: boolean()
  defp isNiceA?(line) do
    cond do
      ~r/([aeiou]{1})/
      |> Regex.scan(line, capture: :first)
      |> Enum.count()
      |> Kernel.<(3) ->
        false

      ~r/([a-z])\1/
      |> Regex.match?(line)
      |> Kernel.!() ->
        false

      ~r/(ab|cd|pq|xy)/ |> Regex.match?(line) ->
        false

      true ->
        true
    end
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.filter(&isNiceA?/1)
    |> Enum.count()
  end

  @spec isNiceB?(binary()) :: boolean()
  defp isNiceB?(line) do
    cond do
      ~r/([a-z]{2}).*\1/
      |> Regex.match?(line)
      |> Kernel.!() ->
        false

      ~r/([a-z]{1}).{1}\1/
      |> Regex.match?(line)
      |> Kernel.!() ->
        false

      true ->
        true
    end
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.filter(&isNiceB?/1)
    |> Enum.count()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> InternElves.part1()
|> IO.puts()

contents
|> InternElves.part2()
|> IO.puts()
