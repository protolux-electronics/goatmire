defmodule Goatmire.Media do
  @moduledoc """
  The Media context.
  """

  import Ecto.Query, warn: false
  alias Goatmire.Repo

  alias Goatmire.Media.Image

  @doc """
  Returns the list of images.

  ## Examples

      iex> list_images()
      [%Image{}, ...]

  """
  def list_approved_images do
    from(i in Image, where: is_nil(i.rejected_at), where: not is_nil(i.approved_at))
    |> Repo.all()
  end

  @doc """
  Gets a single image.

  Raises `Ecto.NoResultsError` if the Image does not exist.

  ## Examples

      iex> get_image!(123)
      %Image{}

      iex> get_image!(456)
      ** (Ecto.NoResultsError)

  """
  def get_image!(id), do: Repo.get!(Image, id)

  @doc """
  Creates a image.

  ## Examples

      iex> create_image(%{field: value})
      {:ok, %Image{}}

      iex> create_image(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_and_process_image(attrs) do
    %Image{}
    |> Image.new_changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, image} ->
        %{"image_id" => image.id}
        |> Goatmire.Media.ProcesImageWorker.new()
        |> Oban.insert()

        {:ok, image}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Updates a image.

  ## Examples

      iex> update_image(image, %{field: new_value})
      {:ok, %Image{}}

      iex> update_image(image, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_image(%Image{} = image, attrs) do
    image
    |> Image.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a image.

  ## Examples

      iex> delete_image(image)
      {:ok, %Image{}}

      iex> delete_image(image)
      {:error, %Ecto.Changeset{}}

  """
  def delete_image(%Image{} = image) do
    Repo.delete(image)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking image changes.

  ## Examples

      iex> change_image(image)
      %Ecto.Changeset{data: %Image{}}

  """
  def change_image(%Image{} = image, attrs \\ %{}) do
    Image.changeset(image, attrs)
  end
end
