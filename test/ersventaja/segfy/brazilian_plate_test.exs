defmodule Ersventaja.Segfy.BrazilianPlateTest do
  use ExUnit.Case, async: true

  alias Ersventaja.Segfy.BrazilianPlate

  test "Mercosul com hífen" do
    assert {:ok, "DAP0J59"} == BrazilianPlate.normalize("dap-0j59")
  end

  test "antiga" do
    assert {:ok, "ABC1234"} == BrazilianPlate.normalize("abc-1234")
  end

  test "fragmento OCR inválido" do
    assert :error == BrazilianPlate.normalize("DAP-9")
    assert :error == BrazilianPlate.normalize("DAP9")
  end

  test "pick_first_valid_plate prefere primeira válida" do
    assert "DAP0J59" ==
             BrazilianPlate.pick_first_valid_plate(["DAP-9", "DAP0J59", "ABC1234"])
  end

  test "pick_first_valid_plate cai no show quando atual é lixo" do
    assert "XYZ9876" ==
             BrazilianPlate.pick_first_valid_plate(["nope", nil, "XYZ9876"])
  end

  describe "correção automática de OCR" do
    test "O corrigido para 0 na posição de dígito (Mercosul)" do
      # EDBOI52 → EDB0I52 (O na posição 4 vira 0)
      assert {:ok, "EDB0I52"} == BrazilianPlate.normalize("EDBOI52")
    end

    test "I corrigido para 1 na posição de dígito (formato antigo)" do
      # ABCI234 → ABC1234
      assert {:ok, "ABC1234"} == BrazilianPlate.normalize("ABCI234")
    end

    test "0 corrigido para O na posição de letra (formato antigo)" do
      # A0C1234 → AOC1234 (0 na pos 2 vira O para formar 3 letras + 4 dígitos)
      assert {:ok, "AOC1234"} == BrazilianPlate.normalize("A0C1234")
    end

    test "múltiplas correções OCR simultâneas" do
      # ABCI2O4 → ABC1204 (I→1 na pos 4, O→0 na pos 6)
      assert {:ok, "ABC1204"} == BrazilianPlate.normalize("ABCI2O4")
    end

    test "placa já válida não é alterada" do
      assert {:ok, "EDB0I52"} == BrazilianPlate.normalize("EDB0I52")
    end

    test "correção impossível retorna error" do
      assert :error == BrazilianPlate.normalize("AAAAAAA")
    end
  end
end
