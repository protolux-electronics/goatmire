defmodule Goatmire.MediaTest do
  use Goatmire.DataCase

  alias Goatmire.Media

  describe "images" do
    alias Goatmire.Media.Image

    import Goatmire.MediaFixtures

    @invalid_attrs %{s3_key: nil, thumbnail_key: nil, dithered_key: nil, alt_text: nil, accept_terms: nil, approved_at: nil, rejected_at: nil}

    test "list_images/0 returns all images" do
      image = image_fixture()
      assert Media.list_images() == [image]
    end

    test "get_image!/1 returns the image with given id" do
      image = image_fixture()
      assert Media.get_image!(image.id) == image
    end

    test "create_image/1 with valid data creates a image" do
      valid_attrs = %{s3_key: "some s3_key", thumbnail_key: "some thumbnail_key", dithered_key: "some dithered_key", alt_text: "some alt_text", accept_terms: true, approved_at: ~U[2025-08-30 15:00:00Z], rejected_at: ~U[2025-08-30 15:00:00Z]}

      assert {:ok, %Image{} = image} = Media.create_image(valid_attrs)
      assert image.s3_key == "some s3_key"
      assert image.thumbnail_key == "some thumbnail_key"
      assert image.dithered_key == "some dithered_key"
      assert image.alt_text == "some alt_text"
      assert image.accept_terms == true
      assert image.approved_at == ~U[2025-08-30 15:00:00Z]
      assert image.rejected_at == ~U[2025-08-30 15:00:00Z]
    end

    test "create_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Media.create_image(@invalid_attrs)
    end

    test "update_image/2 with valid data updates the image" do
      image = image_fixture()
      update_attrs = %{s3_key: "some updated s3_key", thumbnail_key: "some updated thumbnail_key", dithered_key: "some updated dithered_key", alt_text: "some updated alt_text", accept_terms: false, approved_at: ~U[2025-08-31 15:00:00Z], rejected_at: ~U[2025-08-31 15:00:00Z]}

      assert {:ok, %Image{} = image} = Media.update_image(image, update_attrs)
      assert image.s3_key == "some updated s3_key"
      assert image.thumbnail_key == "some updated thumbnail_key"
      assert image.dithered_key == "some updated dithered_key"
      assert image.alt_text == "some updated alt_text"
      assert image.accept_terms == false
      assert image.approved_at == ~U[2025-08-31 15:00:00Z]
      assert image.rejected_at == ~U[2025-08-31 15:00:00Z]
    end

    test "update_image/2 with invalid data returns error changeset" do
      image = image_fixture()
      assert {:error, %Ecto.Changeset{}} = Media.update_image(image, @invalid_attrs)
      assert image == Media.get_image!(image.id)
    end

    test "delete_image/1 deletes the image" do
      image = image_fixture()
      assert {:ok, %Image{}} = Media.delete_image(image)
      assert_raise Ecto.NoResultsError, fn -> Media.get_image!(image.id) end
    end

    test "change_image/1 returns a image changeset" do
      image = image_fixture()
      assert %Ecto.Changeset{} = Media.change_image(image)
    end
  end
end
