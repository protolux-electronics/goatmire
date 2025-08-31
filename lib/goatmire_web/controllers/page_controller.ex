defmodule GoatmireWeb.PageController do
  use GoatmireWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
