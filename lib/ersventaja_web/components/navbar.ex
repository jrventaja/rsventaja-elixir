defmodule ErsventajaWeb.Components.Navbar do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  def navbar(assigns) do
    ~H"""
    <style>
      .fixed-nav {
        position: fixed; top: 0; left: 0; right: 0; width: 100%; z-index: 9999;
        background: linear-gradient(90deg, #3D5FA3 0%, #4A7AC2 35%, #5B9BD5 70%, #7DCDEB 100%);
        height: 50px; display: flex; align-items: center; justify-content: center;
        font-family: 'Playfair Display', Georgia, serif; box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      }
      .nav-desktop-links { display: flex; align-items: center; }
      .nav-link-item { color: white; text-decoration: none; padding: 0.5em 1em; font-size: 16px; letter-spacing: 1px; white-space: nowrap; }
      .nav-link-item:hover { background-color: rgba(167, 215, 250, 0.92); border-radius: 4px; color: rgb(32, 71, 145); font-weight: 600; }
      .nav-brand { display: none; align-items: center; gap: 0.5em; text-decoration: none; }
      .nav-brand-logo { width: 32px; height: 32px; border-radius: 6px; object-fit: cover; }
      .nav-brand-text { color: white; font-family: 'Playfair Display', Georgia, serif; font-size: 17px; font-weight: 700; letter-spacing: 0.5px; }
      .nav-hamburger-btn {
        display: none; background: none; border: none; color: white; cursor: pointer;
        padding: 0; width: 40px; height: 40px; align-items: center; justify-content: center;
        font-size: 20px; border-radius: 6px; transition: background 0.2s;
      }
      .nav-hamburger-btn:hover { background-color: rgba(255,255,255,0.15); }
      .mobile-nav-menu {
        flex-direction: column;
        position: fixed; top: 50px; left: 0; right: 0;
        background: linear-gradient(180deg, #3a5a9e 0%, #2d4a8a 100%);
        z-index: 9998; box-shadow: 0 6px 16px rgba(0,0,0,0.25);
        border-top: 1px solid rgba(255,255,255,0.15);
      }
      .mobile-nav-menu .nav-link-item {
        padding: 1em 1.5em; border-bottom: 1px solid rgba(255,255,255,0.1);
        font-size: 16px; display: block; text-align: left; width: 100%; box-sizing: border-box;
        letter-spacing: 0.5px;
      }
      .mobile-nav-menu .nav-link-item:hover { background-color: rgba(255,255,255,0.12); border-radius: 0; color: white; font-weight: 600; }

      @media (max-width: 768px) {
        .fixed-nav { justify-content: space-between; padding: 0 1em; }
        .nav-desktop-links { display: none; }
        .nav-brand { display: flex; }
        .nav-hamburger-btn { display: flex; }
      }
    </style>

    <nav class="fixed-nav">
      <.link navigate="/" class="nav-brand">
        <img src="/images/rs_logo_transparent.png" alt="RS Ventaja" class="nav-brand-logo" />
        <span class="nav-brand-text">RS Ventaja</span>
      </.link>
      <div class="nav-desktop-links">
        <.link navigate="/" class="nav-link-item">Início</.link>
        <.link navigate="/produtos" class="nav-link-item">Produtos</.link>
        <.link navigate="/seguradoras" class="nav-link-item">Seguradoras</.link>
        <.link navigate="/contato" class="nav-link-item">Contato</.link>
        <.link navigate="/login" class="nav-link-item">Painel de Controle</.link>
      </div>
      <button class="nav-hamburger-btn" phx-click={JS.toggle(to: "#mobile-nav-menu")}>
        <i class="fas fa-bars"></i>
      </button>
    </nav>

    <div id="mobile-nav-menu" class="mobile-nav-menu" style="display: none;">
      <.link navigate="/" class="nav-link-item" phx-click={JS.hide(to: "#mobile-nav-menu")}>
        <i class="fas fa-home" style="margin-right: 0.5em; width: 16px;"></i> Início
      </.link>
      <.link navigate="/produtos" class="nav-link-item" phx-click={JS.hide(to: "#mobile-nav-menu")}>
        <i class="fas fa-shield-alt" style="margin-right: 0.5em; width: 16px;"></i> Produtos
      </.link>
      <.link navigate="/seguradoras" class="nav-link-item" phx-click={JS.hide(to: "#mobile-nav-menu")}>
        <i class="fas fa-building" style="margin-right: 0.5em; width: 16px;"></i> Seguradoras
      </.link>
      <.link navigate="/contato" class="nav-link-item" phx-click={JS.hide(to: "#mobile-nav-menu")}>
        <i class="fas fa-envelope" style="margin-right: 0.5em; width: 16px;"></i> Contato
      </.link>
      <.link navigate="/login" class="nav-link-item" phx-click={JS.hide(to: "#mobile-nav-menu")}>
        <i class="fas fa-lock" style="margin-right: 0.5em; width: 16px;"></i> Painel de Controle
      </.link>
    </div>
    """
  end
end
