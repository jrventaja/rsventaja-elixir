defmodule Ersventaja.Policies.Models.Policy do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder,
           only: [:id, :customer_name, :detail, :start_date, :end_date, :calculated]}

  alias Ersventaja.Policies.Models.Insurer

  @fields ~w(
    customer_name
    detail
    start_date
    end_date
    calculated
    customer_cpf_or_cnpj
    customer_phone
    customer_email
    license_plate
  )a

  @required_fields ~w(
    customer_name
    detail
    start_date
    end_date
    calculated
  )a

  schema "policies" do
    field(:customer_name, :string)
    field(:detail, :string)
    field(:start_date, :date)
    field(:end_date, :date)
    field(:calculated, :boolean)
    field(:customer_cpf_or_cnpj, :string)
    field(:customer_phone, :string)
    field(:customer_email, :string)
    field(:license_plate, :string)

    belongs_to(:insurer, Insurer)

    timestamps()
  end

  @doc false
  def changeset(policy, attrs) do
    policy
    |> cast(attrs, @fields)
    |> validate_required(@required_fields)
  end
end
