defmodule Ersventaja.Repo.Migrations.AddCustomerFieldsToPolicies do
  use Ecto.Migration

  def change do
    alter table(:policies) do
      add :customer_cpf_or_cnpj, :string
      add :customer_phone, :string
      add :customer_email, :string
      add :license_plate, :string
    end
  end
end






