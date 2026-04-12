defmodule Ersventaja.Segfy.BrazilianPlate do
  @moduledoc """
  Placa veicular BR para o multicálculo Segfy: **7 caracteres** alfanuméricos, sem hífen no payload.

  - Formato **antigo**: `AAA9999` (3 letras + 4 dígitos)
  - **Mercosul**: `AAA9A99` (3 letras + dígito + letra + 2 dígitos)

  Valores como `DAP-9` (OCR/policy) são inválidos e não devem sobrescrever a placa vinda do `show`.
  """

  @old ~r/\A[A-Z]{3}[0-9]{4}\z/u
  @mercosul ~r/\A[A-Z]{3}[0-9][A-Z][0-9]{2}\z/u

  # Mapa de substituições OCR: caracteres ambíguos que são frequentemente confundidos
  @ocr_swaps %{?O => [?0], ?0 => [?O], ?I => [?1], ?1 => [?I]}

  @doc """
  Remove separadores, caixa alta, valida padrão BR. Retorna placa **sem hífen** (ex.: `DAP0J59`).

  Quando a placa não corresponde a nenhum formato válido, tenta corrigir
  automaticamente confusões comuns de OCR (O↔0, I↔1).
  """
  @spec normalize(term()) :: {:ok, String.t()} | :error
  def normalize(s) when is_binary(s) do
    raw =
      s
      |> String.trim()
      |> String.upcase()
      |> String.replace(~r/[^A-Z0-9]/u, "")

    cond do
      String.length(raw) != 7 ->
        :error

      Regex.match?(@old, raw) ->
        {:ok, raw}

      Regex.match?(@mercosul, raw) ->
        {:ok, raw}

      true ->
        try_ocr_corrections(raw)
    end
  end

  def normalize(_), do: :error

  # Tenta substituições OCR (O↔0, I↔1) nas posições ambíguas e retorna a
  # primeira combinação que resulta em placa válida.
  @spec try_ocr_corrections(String.t()) :: {:ok, String.t()} | :error
  defp try_ocr_corrections(raw) do
    raw
    |> String.to_charlist()
    |> ocr_variants()
    |> Enum.find_value(:error, fn variant ->
      candidate = List.to_string(variant)

      cond do
        Regex.match?(@old, candidate) -> {:ok, candidate}
        Regex.match?(@mercosul, candidate) -> {:ok, candidate}
        true -> nil
      end
    end)
  end

  # Gera todas as combinações de substituições OCR para os caracteres ambíguos.
  # Ex.: 'EDBOI52' → [~c"EDB0I52", ~c"EDBO152", ~c"EDB0152", ...]
  defp ocr_variants(chars) do
    chars
    |> Enum.reduce([[]], fn char, acc ->
      alternatives = Map.get(@ocr_swaps, char, [])

      Enum.flat_map(acc, fn prefix ->
        for c <- [char | alternatives], do: prefix ++ [c]
      end)
    end)
    # Remove a versão original (já foi testada)
    |> Enum.drop(1)
  end

  @doc false
  def valid?(s), do: match?({:ok, _}, normalize(s))

  @doc false
  def normalize_or_nil(s) do
    case normalize(s) do
      {:ok, p} -> p
      :error -> nil
    end
  end

  @doc """
  Primeira placa válida na ordem (ex.: `[atual, show, policy]`).
  Retorna `""` se nenhuma for válida.
  """
  @spec pick_first_valid_plate([term()]) :: String.t()
  def pick_first_valid_plate(candidates) when is_list(candidates) do
    Enum.find_value(candidates, fn c ->
      case normalize(c) do
        {:ok, p} -> p
        :error -> nil
      end
    end) || ""
  end
end
