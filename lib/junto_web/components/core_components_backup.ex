defmodule JuntoWeb.CoreComponentsBackup do
  @moduledoc """
  Provides core UI components.

  At first glance, this module may seem daunting, but its goal is to provide
  core building blocks for your application, such as modals, tables, and
  forms. The components consist mostly of markup and are well-documented
  with doc strings and declarative assigns. You may customize and style
  them in any way you want, based on your application growth and needs.

  The default components use Tailwind CSS, a utility-first CSS framework.
  See the [Tailwind CSS documentation](https://tailwindcss.com) to learn
  how to customize them or feel free to swap in another framework altogether.

  Icons are provided by [heroicons](https://heroicons.com). See `icon/1` for usage.
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS
  # import JuntoWeb.Gettext

  @doc """
    <.modal id="my-modal" class="bg-red-50" >
      content
    <.modal>
  """
  attr :id, :string, required: true
  attr :class, :string, required: false, default: ""
  slot :inner_block, required: true

  def modal(assigns) do
    ~H"""
    <dialog id={@id} class=" bg-transparent backdrop:bg-black/60 backdrop-grayscale" phx-hook="Dialog">
      <%= render_slot(@inner_block) %>
    </dialog>
    """
  end

  attr :id, :string, required: true
  attr :class, :string, required: false, default: ""

  slot :button, required: true do
    attr :id, :string, required: true
    attr :class, :string, required: false
    attr :"dropdown-toggle", :string, required: false
    attr :"dropdown-delay", :string, required: false
  end

  def dropdown(assigns) do
    button =
      assigns[:button]
      |> List.first()

    assigns = Map.put(assigns, :button, button)

    ~H"""
    <button
      id={@button.id}
      class={@button[:class]}
      data-flowbit-dropdown-custom-toggle={@button[:"dropdown-toggle"]}
      type="button"
      data-flowbit-dropdown-custom-delay={@button[:"toggle-delay"]}
      phx-hook="FlowbitDropdown"
    >
      <%= render_slot(@button) %>
    </button>
    <div class={["hidden ", @class]} id={@id}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.dispatch("showModal", to: "##{id}")
  end
end
