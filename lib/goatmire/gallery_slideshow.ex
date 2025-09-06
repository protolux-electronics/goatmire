defmodule Goatmire.GallerySlideshow do
  use GenServer

  alias Goatmire.Media

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(args) do
    interval = Keyword.get(args, :interval, 10_000)
    timer = :timer.send_interval(interval, :update)

    {:ok, %{update_every: interval, timer: timer, photos: []}}
  end

  @impl true
  def handle_info(:update, state) do
    [image | rest] =
      case state.photos do
        [] -> Media.list_approved_images() |> Enum.shuffle()
        photos -> photos
      end

    GoatmireWeb.Endpoint.broadcast("device_gallery", "image", %{
      url: Goatmire.Utils.presigned_url(image.dithered_key)
    })

    {:noreply, put_in(state.photos, rest)}
  end
end
