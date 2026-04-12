defmodule Mix.Tasks.SegfyTestQuotations do
  @moduledoc """
  Teste integrado: OCR + LLM + Segfy calculate + save.

  Uso:
    mix segfy_test_quotations            # testa todas as apólices do JSON
    mix segfy_test_quotations 3127 3289  # testa apenas os IDs listados
  """
  use Mix.Task

  @fixtures_dir "test/fixtures/segfy_policies"
  @metadata_file Path.join(@fixtures_dir, "policies_metadata.json")

  @impl true
  def run(args) do
    System.put_env("PORT", "#{Enum.random(50000..59999)}")
    System.put_env("PHX_SERVER", "")

    Mix.Task.run("app.start")

    metadata = load_metadata()

    policies =
      case args do
        [] ->
          metadata

        ids ->
          id_set = MapSet.new(ids, &String.to_integer/1)
          Enum.filter(metadata, fn p -> MapSet.member?(id_set, p["id"]) end)
      end

    IO.puts("""

    \e[1m═══════════════════════════════════════════════\e[0m
    \e[1m  Teste Integrado Segfy — COMPLETO (OCR+LLM → Segfy)\e[0m
    \e[1m  #{length(policies)} apólice(s) selecionada(s)\e[0m
    \e[1m═══════════════════════════════════════════════\e[0m
    """)

    results =
      Enum.map(policies, fn p ->
        id = p["id"]
        insurer = p["insurer_name"] || "?"
        name = p["customer_name"] || "?"
        plate = p["license_plate"] || p["detail"] || "?"

        IO.puts("\e[36m  [#{id}] #{name} | #{insurer} | placa: #{plate}\e[0m")

        pdf_path = Path.join(@fixtures_dir, "#{id}.pdf")

        unless File.exists?(pdf_path) do
          IO.puts("\e[33m  [SKIP] PDF não encontrado: #{pdf_path}\e[0m")
          throw({:skip, id, "PDF não encontrado"})
        end

        # Intercept S3 download with local PDF
        file_name = s3_file_name(id)
        Process.put({:segfy_test_local_pdf, file_name}, Path.expand(pdf_path))

        policy = build_policy_struct(p)

        case Ersventaja.Segfy.Quotation.run(policy) do
          {:ok, info} ->
            insurers_with_value = count_insurers_with_value(info)
            total_insurers = count_total_insurers(info)

            if insurers_with_value > 0 do
              IO.puts(
                "\e[32m  [OK] cotação gerada — #{insurers_with_value}/#{total_insurers} seguradora(s) com valor\e[0m"
              )
            else
              IO.puts(
                "\e[33m  [WARN] cotação gerada mas NENHUMA seguradora retornou valor (0/#{total_insurers})\e[0m"
              )

              # Diagnostic: dump raw socket events to understand why 0 insurers
              ren = info[:renovation] || %{}
              all_events = Map.get(ren, :multicalculo_socket_results) || []

              result_events =
                Enum.filter(all_events, fn row ->
                  (row["socket_action"] || "") == "RESULT"
                end)

              IO.puts(
                "    \e[90mDIAG: total_events=#{length(all_events)} result_events=#{length(result_events)}\e[0m"
              )

              for ev <- Enum.take(result_events, 3) do
                detail = ev["result_detail"] || ""

                IO.puts(
                  "    \e[90mDIAG RESULT: status=#{inspect(ev["status"])} company=#{inspect(ev["company_name"])} premium=#{inspect(ev["premium"])} detail=#{String.slice(detail, 0, 120)}\e[0m"
                )
              end
            end

            %{
              id: id,
              status: :ok,
              insurers_with_value: insurers_with_value,
              total_insurers: total_insurers,
              info: info
            }

          {:error, {:calculate_validation, mode, validations}} ->
            IO.puts("\e[31m  [FAIL] Validação Segfy (#{mode}): #{inspect(validations)}\e[0m")

            %{id: id, status: :fail, reason: "Validação: #{inspect(validations)}"}

          {:error, reason} ->
            IO.puts("\e[31m  [FAIL] #{inspect(reason)}\e[0m")

            %{id: id, status: :fail, reason: inspect(reason)}
        end
      end)

    results = Enum.reject(results, &is_nil/1)

    ok = Enum.filter(results, &(&1.status == :ok))
    ok_with_insurers = Enum.filter(ok, &(&1.insurers_with_value > 0))
    ok_without_insurers = Enum.filter(ok, &(&1.insurers_with_value == 0))
    fail = Enum.filter(results, &(&1.status == :fail))

    total = length(results)
    pct_ok = if total > 0, do: Float.round(length(ok) / total * 100, 1), else: 0.0
    pct_full = if total > 0, do: Float.round(length(ok_with_insurers) / total * 100, 1), else: 0.0

    IO.puts("""

    \e[1m═══════════════════════════════════════════════\e[0m
    \e[1m  RELATÓRIO\e[0m
    \e[1m═══════════════════════════════════════════════\e[0m
      Total testadas: #{total}
    \e[32m  Cotação gerada:         #{length(ok)} (#{pct_ok}%)\e[0m
    \e[32m    Com seguradora(s):    #{length(ok_with_insurers)} (#{pct_full}%)\e[0m
    \e[33m    Sem nenhuma (0 val):  #{length(ok_without_insurers)}\e[0m
    \e[31m  Falha:                  #{length(fail)}\e[0m
    """)

    if ok_without_insurers != [] do
      IO.puts("\e[33m  Cotações sem seguradoras (0 valor):\e[0m")

      for r <- ok_without_insurers do
        p = Enum.find(policies, &(&1["id"] == r.id))
        IO.puts("    [#{r.id}] #{p["insurer_name"]} — #{p["customer_name"]}")
      end

      IO.puts("")
    end

    if fail != [] do
      IO.puts("\e[31m  Falhas detalhadas:\e[0m")

      for r <- fail do
        p = Enum.find(policies, &(&1["id"] == r.id))
        IO.puts("    [#{r.id}] #{p["insurer_name"]}: #{r.reason}")
      end

      IO.puts("")
    end

    IO.puts("\e[1m═══════════════════════════════════════════════\e[0m")
  end

  defp load_metadata do
    @metadata_file
    |> File.read!()
    |> Jason.decode!()
  end

  defp s3_file_name(policy_id) do
    key =
      Application.fetch_env!(:ersventaja, :crypto)
      |> Keyword.get(:key)

    hmac = :crypto.mac(:hmac, :sha, key, Integer.to_string(policy_id)) |> Base.encode64()
    Regex.replace(~r/[^\w]/, hmac, "") <> ".pdf"
  end

  defp build_policy_struct(p) do
    %{
      id: p["id"],
      customer_name: p["customer_name"],
      customer_cpf_or_cnpj: p["customer_cpf_or_cnpj"],
      customer_phone: p["customer_phone"],
      customer_email: p["customer_email"],
      license_plate: p["license_plate"] || p["detail"],
      detail: p["detail"],
      start_date: p["start_date"] && Date.from_iso8601!(p["start_date"]),
      end_date: p["end_date"] && Date.from_iso8601!(p["end_date"]),
      insurer_id: p["insurer_id"],
      insurance_type_id: p["insurance_type_id"],
      file_name: s3_file_name(p["id"])
    }
  end

  defp count_insurers_with_value(info) do
    info
    |> extract_socket_results()
    |> Enum.count(fn row ->
      p = row["premium"]
      is_number(p) and p > 0
    end)
  end

  defp count_total_insurers(info) do
    info
    |> extract_socket_results()
    |> length()
  end

  defp extract_socket_results(info) do
    ren = info[:renovation] || %{}
    list = Map.get(ren, :multicalculo_socket_results) || []

    list
    |> Enum.filter(fn row ->
      action = row["socket_action"] || row["action"] || ""
      action == "RESULT"
    end)
    |> Enum.uniq_by(fn row ->
      (row["company_name"] || row["name"] || "") |> String.downcase() |> String.trim()
    end)
  end
end
