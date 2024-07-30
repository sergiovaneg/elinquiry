alias AdventOfCode.Y2015.CorporatePolicy

defmodule AdventOfCode.Y2015.CorporatePolicy do
  @spec increment_password(binary()) :: binary()
  defp increment_password(passwd) do
    {new_passwd, _} =
      passwd
      |> String.downcase()
      |> String.to_charlist()
      |> Enum.reverse()
      |> Enum.map_reduce(1, fn x, acc ->
        cand = x + acc

        if cand > ?z do
          {?a, 1}
        else
          {cand, 0}
        end
      end)

    new_passwd |> Enum.reverse() |> to_string()
  end

  @spec is_valid_passwd?(binary()) :: boolean()
  defp is_valid_passwd?(passwd) do
    cond do
      passwd
      |> String.match?(~r/i|o|l/) ->
        false

      passwd
      |> String.to_charlist()
      |> Enum.chunk_every(3, 1, :discard)
      |> Enum.map(fn triple ->
        triple |> Enum.at(1) == triple |> Enum.at(0) |> Kernel.+(1) &&
            triple |> Enum.at(1) |> Kernel.+(1) == triple |> Enum.at(2)
      end)
      |> Enum.any?()
      |> Kernel.!() ->
        false

      ~r/(.{1})\1/
      |> Regex.scan(passwd)
      |> Enum.uniq()
      |> length()
      |> Kernel.>=(2)
      |> Kernel.!() ->
        false

      true ->
        true
    end
  end

  def get_next_passwd(passwd) do
    passwd
    |> increment_password()
    |> Stream.unfold(fn x ->
      if x |> is_valid_passwd?() do
        nil
      else
        {x, x |> increment_password()}
      end
    end)
    |> Enum.to_list()
    |> List.last()
    |> increment_password()
  end
end

passwd_1 =
  "vzbxkghb"
  |> CorporatePolicy.get_next_passwd()

passwd_1 |> IO.puts()

passwd_1
|> CorporatePolicy.get_next_passwd()
|> IO.puts()
