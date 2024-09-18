alias AdventOfCode.Y2016.InternetProtocol

defmodule AdventOfCode.Y2016.InternetProtocol do
  @abba_regex ~r/([a-z]{1})(?!\1)([a-z]{1})\2\1/
  @aba_regex ~r/\|.*([a-z]{1})(?!\1)([a-z]{1})\1.*\|.*\2\1\2/

  @spec contains_abba?(binary()) :: boolean()
  defp contains_abba?(text) do
    text |> String.match?(@abba_regex)
  end

  @spec supports_tls?(binary()) :: boolean()
  defp supports_tls?(ip) do
    ip
    |> String.split(["[", "]"])
    |> then(fn segments ->
      segments |> Enum.take_every(2) |> Enum.any?(&contains_abba?/1) and
        segments |> Enum.drop_every(2) |> Enum.any?(&contains_abba?/1) |> Kernel.not()
    end)
  end

  @spec part1(binary()) :: non_neg_integer()
  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.count(&supports_tls?/1)
  end

  @spec supports_ssl?(binary()) :: boolean()
  defp supports_ssl?(ip) do
    segments =
      ip
      |> String.split(["[", "]"])

    brackets = segments |> Enum.drop_every(2)
    suffix = segments |> Enum.take_every(2) |> Enum.join(",")

    brackets
    |> Enum.any?(fn prefix ->
      ("|" <> prefix <> "|" <> suffix)
      |> String.match?(@aba_regex)
    end)
  end

  @spec part2(binary()) :: non_neg_integer()
  def part2(contents) do
    contents
    |> String.split("\n")
    |> Enum.count(&supports_ssl?/1)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> InternetProtocol.part1()
|> IO.inspect()

contents
|> InternetProtocol.part2()
|> IO.inspect()
