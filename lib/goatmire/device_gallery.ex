defmodule Goatmire.DeviceGallery do
  use GenServer

  alias Goatmire.Media

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(args) do
    interval = Keyword.get(args, :interval, 5_000)
    timer = :timer.send_interval(interval, :update)

    {:ok, %{update_every: interval}}
  end

  @impl true
  def handle_info(:update, state) do
    image =
      Media.list_approved_images()
      |> Enum.shuffle()
      |> List.first()

    Phoenix.PubSub.broadcast(Goatmire.PubSub, "device_gallery", {:gallery_image, image})

    {:noreply, state}
  end
end
