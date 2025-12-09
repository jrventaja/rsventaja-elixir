defmodule ErsventajaWeb.LayoutView do
  use Phoenix.Component
  use Phoenix.HTML
  alias ErsventajaWeb.Router.Helpers, as: Routes

  # Phoenix LiveDashboard is available only in development by default,
  # so we instruct Elixir to not warn if the dashboard route is missing.
  @compile {:no_warn_undefined, {Routes, :live_dashboard_path, 2}}

  def root(assigns) do
    conn_or_socket = assigns[:conn] || assigns[:socket] || assigns.socket
    page_title = assigns[:page_title] || Map.get(assigns, :page_title, "RS Ventaja")

    assigns = assign(assigns, :conn_or_socket, conn_or_socket)
    assigns = assign(assigns, :page_title, page_title)

    ~H"""
    <!DOCTYPE html>
    <html lang="pt-BR">
      <head>
        <meta charset="utf-8"/>
        <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <meta name="csrf-token" content={csrf_token_value()}>
        <.live_title suffix=" · Corretora de Seguros"><%= @page_title %></.live_title>

        <!-- Tailwind CSS CDN -->
        <script src="https://cdn.tailwindcss.com"></script>

        <!-- Google Fonts - Playfair Display (Classic Serif) -->
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:ital,wght@0,400;0,500;0,600;1,400&display=swap" rel="stylesheet">

        <!-- FontAwesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" integrity="sha512-iecdLmaskl7CVkqkXNQ/ZH/XLlvWZOJyj7Yy7tcenmpD1ypASozpmT/E0iPtmFIB46ZmdtAc9eNBvH0H/ZpiBw==" crossorigin="anonymous" referrerpolicy="no-referrer" />

        <!-- App assets -->
        <link phx-track-static rel="stylesheet" href={Routes.static_path(@conn_or_socket, "/assets/app.css")}/>

        <!-- Hooks e funções de máscara - DEVEM ser definidos ANTES do app.js -->
        <script>
          // Máscaras de formatação - definidas globalmente
          window.maskCpfCnpj = function(value) {
            if (!value) return '';
            value = value.replace(/\D/g, '');
            if (value.length <= 11) {
              // CPF: 000.000.000-00
              value = value.replace(/(\d{3})(\d)/, '$1.$2');
              value = value.replace(/(\d{3})(\d)/, '$1.$2');
              value = value.replace(/(\d{3})(\d{1,2})$/, '$1-$2');
            } else {
              // CNPJ: 00.000.000/0000-00
              value = value.substring(0, 14);
              value = value.replace(/^(\d{2})(\d)/, '$1.$2');
              value = value.replace(/^(\d{2})\.(\d{3})(\d)/, '$1.$2.$3');
              value = value.replace(/\.(\d{3})(\d)/, '.$1/$2');
              value = value.replace(/(\d{4})(\d)/, '$1-$2');
            }
            return value;
          };

          window.maskPhone = function(value) {
            if (!value) return '';
            value = value.replace(/\D/g, '');
            value = value.substring(0, 11);
            if (value.length <= 10) {
              // Telefone fixo: (00) 0000-0000
              value = value.replace(/^(\d{2})(\d)/g, '($1) $2');
              value = value.replace(/(\d{4})(\d)/, '$1-$2');
            } else {
              // Celular: (00) 00000-0000
              value = value.replace(/^(\d{2})(\d)/g, '($1) $2');
              value = value.replace(/(\d{5})(\d)/, '$1-$2');
            }
            return value;
          };

          window.validateCpfCnpj = function(value) {
            const cleaned = value.replace(/\D/g, '');
            if (cleaned.length === 11) {
              return window.validateCpf(cleaned);
            } else if (cleaned.length === 14) {
              return window.validateCnpj(cleaned);
            }
            return false;
          };

          window.validateCpf = function(cpf) {
            if (/^(\d)\1+$/.test(cpf)) return false;
            let sum = 0;
            for (let i = 0; i < 9; i++) sum += parseInt(cpf[i]) * (10 - i);
            let digit1 = (sum * 10) % 11;
            if (digit1 === 10) digit1 = 0;
            if (digit1 !== parseInt(cpf[9])) return false;
            sum = 0;
            for (let i = 0; i < 10; i++) sum += parseInt(cpf[i]) * (11 - i);
            let digit2 = (sum * 10) % 11;
            if (digit2 === 10) digit2 = 0;
            return digit2 === parseInt(cpf[10]);
          };

          window.validateCnpj = function(cnpj) {
            if (/^(\d)\1+$/.test(cnpj)) return false;
            const weights1 = [5,4,3,2,9,8,7,6,5,4,3,2];
            const weights2 = [6,5,4,3,2,9,8,7,6,5,4,3,2];
            let sum = 0;
            for (let i = 0; i < 12; i++) sum += parseInt(cnpj[i]) * weights1[i];
            let digit1 = sum % 11 < 2 ? 0 : 11 - (sum % 11);
            if (digit1 !== parseInt(cnpj[12])) return false;
            sum = 0;
            for (let i = 0; i < 13; i++) sum += parseInt(cnpj[i]) * weights2[i];
            let digit2 = sum % 11 < 2 ? 0 : 11 - (sum % 11);
            return digit2 === parseInt(cnpj[13]);
          };

          window.applyValidationStyle = function(el, maskType) {
            const cleaned = el.value.replace(/\D/g, '');
            if (maskType === 'cpf-cnpj') {
              if (cleaned.length === 11 || cleaned.length === 14) {
                if (window.validateCpfCnpj(el.value)) {
                  el.style.borderColor = '#10b981';
                  el.style.boxShadow = '0 0 0 3px rgba(16, 185, 129, 0.1)';
                } else {
                  el.style.borderColor = '#ef4444';
                  el.style.boxShadow = '0 0 0 3px rgba(239, 68, 68, 0.1)';
                }
              } else {
                el.style.borderColor = '';
                el.style.boxShadow = '';
              }
            } else if (maskType === 'phone') {
              if (cleaned.length >= 10 && cleaned.length <= 11) {
                el.style.borderColor = '#10b981';
                el.style.boxShadow = '0 0 0 3px rgba(16, 185, 129, 0.1)';
              } else {
                el.style.borderColor = '';
                el.style.boxShadow = '';
              }
            }
          };

          // Hooks do LiveView para máscaras
          window.Hooks = window.Hooks || {};

          window.Hooks.MaskCpfCnpj = {
            mounted() {
              this.el.value = window.maskCpfCnpj(this.el.value);
              window.applyValidationStyle(this.el, 'cpf-cnpj');

              this.el.addEventListener('input', (e) => {
                const start = e.target.selectionStart;
                const oldLength = e.target.value.length;
                e.target.value = window.maskCpfCnpj(e.target.value);
                const newLength = e.target.value.length;
                const cursorPos = Math.max(0, start + (newLength - oldLength));
                try { e.target.setSelectionRange(cursorPos, cursorPos); } catch(err) {}
                window.applyValidationStyle(e.target, 'cpf-cnpj');
              });
            },
            updated() {
              this.el.value = window.maskCpfCnpj(this.el.value);
              window.applyValidationStyle(this.el, 'cpf-cnpj');
            }
          };

          window.Hooks.MaskPhone = {
            mounted() {
              this.el.value = window.maskPhone(this.el.value);
              window.applyValidationStyle(this.el, 'phone');

              this.el.addEventListener('input', (e) => {
                const start = e.target.selectionStart;
                const oldLength = e.target.value.length;
                e.target.value = window.maskPhone(e.target.value);
                const newLength = e.target.value.length;
                const cursorPos = Math.max(0, start + (newLength - oldLength));
                try { e.target.setSelectionRange(cursorPos, cursorPos); } catch(err) {}
                window.applyValidationStyle(e.target, 'phone');
              });
            },
            updated() {
              this.el.value = window.maskPhone(this.el.value);
              window.applyValidationStyle(this.el, 'phone');
            }
          };

          document.addEventListener("DOMContentLoaded", function() {
            // File upload handler
            document.body.addEventListener("change", function(e) {
              if (e.target.type === "file" && e.target.files && e.target.files.length > 0) {
                const view = document.querySelector("[data-phx-main]")?.__view;
                if (view) {
                  view.pushEvent("file_selected", {});
                }
              }
            });
          });
        </script>

        <!-- App.js carregado DEPOIS dos hooks serem definidos -->
        <script defer phx-track-static type="text/javascript" src={Routes.static_path(@conn_or_socket, "/assets/app.js")}></script>

        <style>
          html { width: 100%; }
          body { margin: 0; padding: 0; width: 100%; max-width: 100%; overflow-x: hidden; }
          * { box-sizing: border-box; }
        </style>
      </head>
      <body>
        <%= @inner_content %>
      </body>
    </html>
    """
  end

  def live(assigns) do
    ~H"""
    <main style="width: 100%; max-width: 100%; margin: 0; padding: 0;">
      <p class="alert alert-info" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="info"><%= live_flash(@flash, :info) %></p>

      <p class="alert alert-danger" role="alert"
        phx-click="lv:clear-flash"
        phx-value-key="error"><%= live_flash(@flash, :error) %></p>

      <%= @inner_content %>
    </main>
    """
  end
end
