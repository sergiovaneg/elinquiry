alias AdventOfCode.Y2015.LetSnow

defmodule AdventOfCode.Y2015.LetSnow do
  @target_row 3010
  @target_col 3019

  @spec part1() :: non_neg_integer()
  def part1() do
    b = @target_col + @target_row

    1..((b * b / 2) |> round())
    |> Enum.reduce_while({20_151_125, 1, 1}, fn _, {code, row, col} ->
      if row == @target_row && col == @target_col do
        {:halt, code}
      else
        next_code = (code * 252_533) |> Kernel.rem(33_554_393)

        if row == 1 do
          {:cont, {next_code, col + 1, 1}}
        else
          {:cont, {next_code, row - 1, col + 1}}
        end
      end
    end)
  end
end

LetSnow.part1() |> IO.puts()
