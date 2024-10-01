alias AdventOfCode.Y2016.DragonChecksum

defmodule AdventOfCode.Y2016.DragonChecksum do
  @initial_state "01110110101001000"
  @target_length_1 272
  @target_length_2 35_651_584

  defp checksum(seed) do
    if seed |> String.length() |> rem(2) == 1 do
      seed
    else
      seed
      |> String.replace(
        ~r/.{2}/,
        fn <<a, b>> -> if(a == b, do: "1", else: "0") end
      )
      |> checksum()
    end
  end

  defp expand(seed, target_len) do
    if seed |> String.length() >= target_len do
      seed
      |> String.slice(0..(target_len - 1))
    else
      (seed <>
         "0" <>
         (seed
          |> String.reverse()
          |> String.replace(
            ~r/.{1}/,
            fn bit ->
              if(bit == "1", do: "0", else: "1")
            end
          )))
      |> expand(target_len)
    end
  end

  def part1() do
    @initial_state
    |> expand(@target_length_1)
    |> checksum()
  end

  def part2() do
    @initial_state
    |> expand(@target_length_2)
    |> checksum()
  end
end

DragonChecksum.part1()
|> IO.puts()

DragonChecksum.part2()
|> IO.puts()
