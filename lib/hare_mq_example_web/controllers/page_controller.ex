defmodule HareMqExampleWeb.PageController do
  use HareMqExampleWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
