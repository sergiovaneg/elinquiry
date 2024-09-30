alias AdventOfCode.Y2016.TimingEverything

defmodule AdventOfCode.Y2016.TimingEverything do
  @typep disc :: {non_neg_integer(), pos_integer()}

  defp extended_gcd(old_r, 0, old_s, _s, old_t, _t), do: {old_r, old_s, old_t}

  defp extended_gcd(old_r, r, old_s, s, old_t, t) do
    q = div(old_r, r)

    extended_gcd(r, old_r - q * r, s, old_s - q * s, t, old_t - q * t)
  end

  defp extended_gcd(a, b) do
    extended_gcd(a, b, 1, 0, 0, 1)
  end

  @spec normalize_disc(disc(), non_neg_integer()) :: disc()
  defp normalize_disc({offset, period}, position),
    do: {
      Integer.mod(position + offset, period),
      period
    }

  @spec parse_disc(binary()) :: disc()
  defp parse_disc(line) do
    {
      ~r/([0-9]+)\./
      |> Regex.run(line, capture: :all_but_first)
      |> List.flatten()
      |> List.first()
      |> String.to_integer(),
      ~r/([0-9]+) positions/
      |> Regex.run(line, capture: :all_but_first)
      |> List.flatten()
      |> List.first()
      |> String.to_integer()
    }
  end

  def part1(contents) do
    contents
    |> String.split("\n")
    |> Enum.map(&parse_disc/1)
    |> then(fn discs ->
      discs
      |> Enum.zip_with(1..length(discs), &normalize_disc/2)
      |> Enum.reduce({0, 1}, fn {tau_b, t_b}, {tau_a, t_a} ->
        {g, s, _t} = extended_gcd(t_a, t_b)
        z = div(tau_a - tau_b, g)

        t_c = div(t_a * t_b, g)
        tau_c = Integer.mod(tau_a - z * s * t_a, t_c)
        {tau_c, t_c}
      end)
    end)
    |> then(fn {tau, t} -> Integer.mod(t - tau, t) end)
  end

  def part2(contents) do
    (contents <> "\nDisc #7 has 11 positions; at time=0, it is at position 0.")
    |> part1()
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> TimingEverything.part1()
|> IO.inspect()

contents
|> TimingEverything.part2()
|> IO.inspect()
