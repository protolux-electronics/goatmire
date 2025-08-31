defmodule Goatmire.Media.Image do
  use Goatmire.Schema
  import Ecto.Changeset

  schema "images" do
    field :s3_key, :string
    field :thumbnail_key, :string
    field :dithered_key, :string
    field :alt_text, :string
    field :accept_terms, :boolean, default: false
    field :approved_at, :utc_datetime
    field :rejected_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(image, attrs) do
    image
    |> cast(attrs, [
      :s3_key,
      :thumbnail_key,
      :dithered_key,
      :alt_text,
      :accept_terms,
      :approved_at,
      :rejected_at
    ])
    |> validate_common()
  end

  def new_changeset(image, attrs) do
    image
    |> cast(attrs, [:s3_key, :alt_text, :accept_terms])
    |> validate_required([:s3_key])
    |> validate_common()
  end

  defp validate_common(changeset) do
    changeset
    |> validate_required([:alt_text, :accept_terms])
    |> validate_acceptance(:accept_terms, message: "You must agree to the terms")
    |> validate_length(:alt_text,
      min: 20,
      message: "To support accessibility, please add a description of at least 20 characters"
    )
  end
end
