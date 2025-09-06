defmodule Goatmire.Utils do
  def presigned_url(key) do
    today =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.beginning_of_day()

    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(:get, bucket(), key,
      start_datetime: today,
      expires_in: 24 * 60 * 60
    )
    |> case do
      {:ok, url} -> url
      _ -> nil
    end
  end

  def bucket, do: Application.get_env(:ex_aws, :s3) |> Keyword.fetch!(:bucket)
end
