alias AdventOfCode.Y2015.Matchsticks

defmodule AdventOfCode.Y2015.Matchsticks do
  @r1 ~r/(^\")|(\"$)/ui
  @r2 ~r/(\\x)([a-f|0-9]{2})/ui
  @r3 ~r/(\\)(.{1})/ui

  @spec decode_special(binary()) :: binary()
  defp decode_special(line) do
    line
    |> (&Regex.replace(@r1, &1, "")).()
    |> (&Regex.replace(@r2, &1, fn _, _, code ->
          [code |> String.to_integer(16)] |> List.to_string()
        end)).()
    |> (&Regex.replace(@r3, &1, fn _, _, x -> x end)).()
  end

  @spec encode_special(binary()) :: binary()
  defp encode_special(line) do
    line
    |> (&Regex.replace(
          @r3,
          &1,
          fn x ->
            if x |> String.ends_with?("x") do
              "\\" <> x
            else
              "\\\\" <> x
            end
          end,
          options: :first
        )).()
    |> (&Regex.replace(@r1, &1, "\"\\\"")).()
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(fn line ->
      decoded_length = line |> decode_special() |> String.length()

      line
      |> String.length()
      |> Kernel.-(decoded_length)
    end)
    |> Enum.sum()
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(fn line ->
      original_length = line |> String.length()

      line
      |> encode_special()
      |> String.length()
      |> Kernel.-(original_length)
    end)
    |> Enum.sum()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> Matchsticks.part1()
|> IO.puts()

contents
|> Matchsticks.part2()
|> IO.puts()
