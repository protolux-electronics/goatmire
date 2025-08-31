defmodule Goatmire.Media.ProcesImageWorker do
  use Oban.Worker, queue: :default, max_attempts: 3

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"image_id" => image_id}}) do
    IO.inspect("Process image (id: #{image_id}) resizing and dithering", label: "TODO")
    :ok
  end
end
