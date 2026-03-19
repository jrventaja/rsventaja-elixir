defmodule ErsventajaWeb.Components.Hero do
  use Phoenix.Component

  attr(:title, :string, required: true)
  attr(:subtitle, :string, default: nil)

  def hero(assigns) do
    ~H"""
    <style>
      .hero-section {
        margin-top: 50px; width: 100% !important; max-width: 100% !important;
        background-color: rgb(39, 39, 39);
        display: flex; align-items: center; justify-content: center;
        position: relative; height: 350px;
      }
      .hero-logo { width: 140px; height: 140px; margin-bottom: 1.5em; }
      .hero-title { font-size: 48px; margin: 0; font-weight: 400; color: white; letter-spacing: 2px; font-family: 'Playfair Display', Georgia, serif; }
      .hero-subtitle { font-size: 20px; font-style: italic; margin: 0.5em 0 0 0; color: white; font-family: 'Playfair Display', Georgia, serif; }

      @media (max-width: 768px) {
        .hero-section { height: 220px; }
        .hero-logo { width: 80px; height: 80px; margin-bottom: 0.75em; }
        .hero-title { font-size: 28px; letter-spacing: 1px; }
        .hero-subtitle { font-size: 15px; }
      }
    </style>

    <div class="hero-section">
      <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; padding: 0 1em;">
        <img alt="RS Ventaja" src="/images/rs_logo_transparent.png" class="hero-logo" />
        <h1 class="hero-title"><%= @title %></h1>
        <%= if @subtitle do %>
          <p class="hero-subtitle"><%= @subtitle %></p>
        <% end %>
      </div>
    </div>
    """
  end
end
