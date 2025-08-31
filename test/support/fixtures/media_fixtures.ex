defmodule Goatmire.MediaFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Goatmire.Media` context.
  """

  @doc """
  Generate a image.
  """
  def image_fixture(attrs \\ %{}) do
    {:ok, image} =
      attrs
      |> Enum.into(%{
        accept_terms: true,
        alt_text: "some alt_text",
        approved_at: ~U[2025-08-30 15:00:00Z],
        dithered_key: "some dithered_key",
        rejected_at: ~U[2025-08-30 15:00:00Z],
        s3_key: "some s3_key",
        thumbnail_key: "some thumbnail_key"
      })
      |> Goatmire.Media.create_image()

    image
  end
end
