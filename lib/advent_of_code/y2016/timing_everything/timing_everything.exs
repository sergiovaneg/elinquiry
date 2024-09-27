alias AdventOfCode.Y2016.TimingEverything

defmodule AdventOfCode.Y2016.TimingEverything do
  @typep disc :: {non_neg_integer(), pos_integer()}

  def gcd(a, 0), do: a
  def gcd(0, b), do: b
  def gcd(a, b), do: gcd(b, Integer.mod(a, b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a * b, gcd(a, b))

  defp extended_gcd(_, 0, old_s, old_r), do: {old_s, old_r}

  defp extended_gcd(s, r, old_s, old_r) do
    q = div(old_r, r)

    extended_gcd(old_s - q * s, old_r - q * r, s, r)
  end

  defp extended_gcd(a, b) do
    {old_s, old_r} = extended_gcd(0, b, 1, a)

    {
      old_s,
      if(b == 0, do: 0, else: div(old_r - old_s * a, b)),
      old_r
    }
  end

  @spec normalize_disc(disc(), non_neg_integer()) :: disc()
  defp normalize_disc({offset, period}, position),
    do: {
      rem(position + offset, period),
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
        {s, _, g} = extended_gcd(t_a, t_b)
        z = div(tau_a - tau_b, g)

        t_c = lcm(t_a, t_b)
        tau_c = Integer.mod(-z * s * t_a + tau_a, t_c)
        {tau_c, t_c}
      end)
    end)
  end
end

contents = File.read!("./input.txt") |> String.trim()

contents
|> TimingEverything.part1()
|> IO.inspect()
