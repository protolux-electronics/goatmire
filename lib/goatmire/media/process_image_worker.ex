defmodule Goatmire.Media.ProcesImageWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  alias Goatmire.Media

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"image_id" => image_id}}) do
    image = Media.get_image!(image_id)

    {:ok, %{body: body}} =
      ExAws.S3.get_object(bucket(), image.s3_key)
      |> ExAws.request()

    with {:ok, img} <- Dither.decode(body),
         {:ok, img_small} <- Dither.resize(img, 400, 300),
         {:ok, png_color} <- Dither.encode(img_small),
         {:ok, img_dithered} <- Dither.dither(img_small, algorithm: :sierra),
         {:ok, png_dithered} <- Dither.encode(img_dithered) do
      key_base =
        image.s3_key
        |> Path.split()
        |> Enum.drop(-1)
        |> Path.join()

      data = [
        {:dithered_key, generate_key(key_base), png_dithered},
        {:thumbnail_key, generate_key(key_base), png_color}
      ]

      keys =
        data
        |> Enum.map(fn {key, value, _data} -> {key, value} end)
        |> Map.new()

      for {_, key, obj} <- data do
        ExAws.S3.put_object(bucket(), key, obj, content_type: "image/png")
        |> ExAws.request!()
      end

      {:ok, _image} = Media.update_image_keys(image, keys)
    end

    :ok
  end

  defp bucket, do: Application.get_env(:ex_aws, :s3) |> Keyword.fetch!(:bucket)
  defp generate_key(key_base), do: Path.join(key_base, "#{Ecto.UUID.generate()}.png")
end
