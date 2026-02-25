defmodule ErsventajaWeb.PrivacidadeLive do
  use ErsventajaWeb, :live_view
  import ErsventajaWeb.Components.Navbar
  import ErsventajaWeb.Components.Hero

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <style>
      body { margin: 0; padding: 0; font-family: 'Playfair Display', Georgia, serif; color: #504f4f; }
      .main-content { background-color: white; min-height: 100vh; }
      .section { padding: 3em 2em; max-width: 800px; margin: 0 auto; text-align: left; }
      .section-title { font-size: 32px; font-weight: 400; letter-spacing: 2px; margin-bottom: 1em; color: #504f4f; }
      .policy-text { font-size: 16px; line-height: 1.8; color: #444; }
      .policy-text h3 { font-size: 20px; margin-top: 1.5em; margin-bottom: 0.5em; color: #504f4f; }
      .policy-text p { margin-bottom: 1em; }
      .policy-text a { color: #2346ae; text-decoration: none; }
      .policy-text a:hover { text-decoration: underline; }
    </style>

    <.navbar />
    <.hero title="RS Ventaja" subtitle="Corretora de Seguros" />

    <div class="main-content">
      <section class="section">
        <h2 class="section-title">Política de Privacidade</h2>
        <div class="policy-text">
          <p><em>Última atualização: fevereiro de 2025</em></p>

          <p>
            A RS Ventaja Corretora de Seguros ("nós", "nosso") respeita sua privacidade e está comprometida com a proteção dos seus dados pessoais, em conformidade com a Lei Geral de Proteção de Dados (LGPD – Lei nº 13.709/2018).
          </p>

          <h3>1. Responsável pelo tratamento</h3>
          <p>
            O responsável pelo tratamento dos dados pessoais é a RS Ventaja Corretora de Seguros. Para questões relativas a esta política ou aos seus dados, entre em contato: <a href="mailto:roberto@rsventaja.com">roberto@rsventaja.com</a>.
          </p>

          <h3>2. Dados que coletamos</h3>
          <p>
            Podemos coletar e processar os seguintes dados:
          </p>
          <ul>
            <li><strong>No site:</strong> informações que você nos envia pelo formulário de contato (nome, e-mail, telefone, mensagem).</li>
            <li><strong>No atendimento por WhatsApp:</strong> número de telefone, mensagens trocadas e, quando você solicita o download de apólice, o CPF ou CNPJ informado para identificação e emissão do link de download.</li>
            <li><strong>No painel administrativo:</strong> dados das apólices e clientes cadastrados para prestação dos serviços de corretagem.</li>
          </ul>

          <h3>3. Finalidade do tratamento</h3>
          <p>
            Utilizamos os dados para: atendimento ao cliente, envio de informações sobre seguros, geração de links seguros para download de apólices, cumprimento de obrigações legais e melhoria dos nossos serviços.
          </p>

          <h3>4. Base legal</h3>
          <p>
            O tratamento é realizado com base no seu consentimento (quando você nos envia dados ou usa o WhatsApp), na execução de contrato ou de medidas pré-contratuais, e no legítimo interesse para operação e segurança dos nossos sistemas.
          </p>

          <h3>5. Compartilhamento</h3>
          <p>
            Não vendemos seus dados. Podemos compartilhar dados apenas com seguradoras e parceiros necessários à contratação e à gestão dos seguros, ou quando exigido por lei.
          </p>

          <h3>6. Retenção e segurança</h3>
          <p>
            Mantemos os dados pelo tempo necessário às finalidades descritas e às obrigações legais. Adotamos medidas técnicas e organizacionais para proteger os dados contra acesso não autorizado, perda ou alteração.
          </p>

          <h3>7. Seus direitos (LGPD)</h3>
          <p>
            Você tem direito a: acesso aos seus dados, correção de dados incompletos ou desatualizados, anonimização ou eliminação de dados desnecessários, portabilidade, revogação do consentimento (quando aplicável) e informação sobre compartilhamento. Para exercer esses direitos, entre em contato pelo e-mail <a href="mailto:roberto@rsventaja.com">roberto@rsventaja.com</a>.
          </p>

          <h3>8. Alterações</h3>
          <p>
            Esta política pode ser atualizada. A data da última atualização será indicada no topo da página. O uso continuado do site ou do atendimento por WhatsApp após alterações constitui aceite da nova versão.
          </p>

          <p>
            <a href="/">Voltar ao início</a>
          </p>
        </div>
      </section>
    </div>
    """
  end
end
