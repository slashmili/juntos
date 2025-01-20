defmodule JuntosWeb.CoreComponents do
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
  use Gettext, backend: JuntosWeb.Gettext

  alias Phoenix.LiveView.JS

  attr :variant, :string,
    values: ~w(primary secondary link outline),
    default: "primary",
    doc: "the button variant style"

  attr :size, :string, default: "lg", values: ~w(lg md)
  attr :type, :string, default: "submit", values: ~w(submit button reset)
  attr :class, :any, default: nil
  attr :icon_right, :string, default: nil
  attr :icon_left, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)

  slot :inner_block, required: true

  @doc """
  Renders a button.
  """
  def button(assigns) do
    assigns = Map.put(assigns, :variant_class, button_variant_class(assigns))
    assigns = Map.put(assigns, :size_class, button_size_class(assigns))
    assigns = Map.put(assigns, :icon_class, button_icon_class(assigns))

    ~H"""
    <button
      type={@type}
      class={[
        @variant_class,
        @size_class,
        @class,
        "flex gap-1  font-medium  max-w-md"
      ]}
      {@rest}
    >
      <.icon :if={@icon_left} name={@icon_left} class={@icon_class} />
      {render_slot(@inner_block)}
      <.icon :if={@icon_right} name={@icon_right} class={@icon_class} />
    </button>
    """
  end

  defp button_icon_class(assigns) do
    case assigns[:size] do
      "md" -> "w-4 h-4"
      _ -> "w-6 h-6"
    end
  end

  defp button_size_class(assigns) do
    case assigns[:size] do
      "md" -> "rounded-full p-3"
      _ -> "rounded-lg px-3 py-3 px-2"
    end
  end

  defp button_variant_class(%{variant: "secondary"} = assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400"
      else
        "bg-violet-100 text-violet-700 dark:bg-violet-950 dark:text-violet-200"
      end

    colors
  end

  defp button_variant_class(%{variant: "outline"} = assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400 border-gray-300 dark:bg-gray-900 dark:text-gray-700 dark:border-gray-700"
      else
        "bg-slate-50 text-slate-900 border-slate-200 dark:bg-slate-800 dark:text-slate-300 dark:border-slate-600"
      end

    ["border-2", colors]
  end

  defp button_variant_class(%{variant: "link"} = assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400 dark:bg-gray-900 dark:text-gray-700"
      else
        "text-slate-600 dark:text-slate-400"
      end

    ["border-0", colors]
  end

  defp button_variant_class(assigns) do
    colors =
      if assigns[:rest][:disabled] do
        "bg-gray-200 text-gray-400"
      else
        "bg-violet-700 text-slate-50"
      end

    colors
  end

  attr :logged_in, :boolean, default: false

  def navbar(assigns) do
    ~H"""
    <navbar class="flex max-w-6xl w-full pt-2 py-4 shadow">
      <div class="flex">
        <.button variant="link" icon_right="logo"></.button>
        <.button variant="link" icon_right="hero-magnifying-glass"></.button>
      </div>
      <div :if={@logged_in} class="grow flex justify-end">
        <.button variant="outline" size="md">Create event</.button>
        <.button variant="link" icon_right="hero-bell"></.button>
        <.button variant="link" icon_right="hero-user-solid"></.button>
      </div>
    </navbar>
    """
  end

  @doc """
  Render Hero section
  """

  slot :title, doc: "the title block", required: true
  slot :subtitle, doc: "the optional subtitle block"
  slot :body, doc: "the optional body block"

  def hero(assigns) do
    ~H"""
    <section class="max-w-md text-center pt-8 flex gap-2 flex-col">
      <div class="text-3xl font-semibold text-slate-900 dark:text-slate-200">
        {render_slot(@title)}
      </div>
      <div :if={@subtitle} class="text-base font-normal text-slate-500 dark:text-slate-400">
        {render_slot(@subtitle)}
      </div>
      <div :if={@body} class="text-base font-normal text-slate-900 dark:text-slate-200">
        {render_slot(@body)}
      </div>
    </section>
    """
  end

  attr :placeholder, :string, default: ""
  attr :icon_left, :string, default: nil
  attr :icon_right, :string, default: nil

  def input_text(assigns) do
    ~H"""
    <section>
      <div class="text-slate-600 dark:text-slate-400 pb-0.5">{@label}</div>
      <div class="px-3 py-2 border border-slate-400 rounded-lg flex gap-2 text-slate-400 dark:text-slate-500 focus-within:text-slate-900 dark:focus-within:text-slate-400 focus-within:border-2">
        <div :if={@icon_left}>
          <.icon name={@icon_left} class="w-6 h-6" />
        </div>
        <input
          class="border-0 p-0 m-0 outline-none text-slate-900 dark:text-slate-400 placeholder-slate-400  dark:placeholder-slate-500 focus:ring-0 bg-transparent"
          type="text"
          placeholder={@placeholder}
        />
        <div :if={@icon_right}>
          <.icon name={@icon_right} class="w-6 h-6" />
        </div>
      </div>
    </section>
    """
  end

  @doc """
  Renders flash notices.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash kind={:info} phx-mounted={show("#flash")}>Welcome Back!</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      class={[
        "fixed top-2 right-2 mr-2 w-80 sm:w-96 z-50 rounded-lg p-3 ring-1",
        @kind == :info && "bg-emerald-50 text-emerald-800 ring-emerald-500 fill-cyan-900",
        @kind == :error && "bg-rose-50 text-rose-900 shadow-md ring-rose-500 fill-rose-900"
      ]}
      {@rest}
    >
      <p :if={@title} class="flex items-center gap-1.5 text-sm font-semibold leading-6">
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="h-4 w-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="h-4 w-4" />
        {@title}
      </p>
      <p class="mt-2 text-sm leading-5">{msg}</p>
      <button type="button" class="group absolute top-1 right-1 p-2" aria-label={gettext("close")}>
        <.icon name="hero-x-mark-solid" class="h-5 w-5 opacity-40 group-hover:opacity-70" />
      </button>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id}>
      <.flash kind={:info} title={gettext("Success!")} flash={@flash} />
      <.flash kind={:error} title={gettext("Error!")} flash={@flash} />
      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error")}
        phx-connected={hide("#client-error")}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error")}
        phx-connected={hide("#server-error")}
        hidden
      >
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :string, default: nil

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end

  def icon(%{name: "logo"} = assigns) do
    ~H"""
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g clip-path="url(#clip0_139_1721)">
        <path
          fill-rule="evenodd"
          clip-rule="evenodd"
          d="M18 2H6C3.79086 2 2 3.79086 2 6V18C2 20.2091 3.79086 22 6 22H18C20.2091 22 22 20.2091 22 18V6C22 3.79086 20.2091 2 18 2ZM6 0C2.68629 0 0 2.68629 0 6V18C0 21.3137 2.68629 24 6 24H18C21.3137 24 24 21.3137 24 18V6C24 2.68629 21.3137 0 18 0H6Z"
          fill="#475569"
        />
        <circle
          cx="7.27037"
          cy="17.0709"
          r="2.3125"
          transform="rotate(-45 7.27037 17.0709)"
          fill="#475569"
        />
        <circle
          cx="12.0082"
          cy="12.0081"
          r="2.3125"
          transform="rotate(-45 12.0082 12.0081)"
          fill="#475569"
        />
        <circle
          cx="17.0709"
          cy="7.27039"
          r="2.3125"
          transform="rotate(-45 17.0709 7.27039)"
          fill="#475569"
        />
      </g>
      <defs>
        <clipPath id="clip0_139_1721">
          <rect width="24" height="24" fill="white" />
        </clipPath>
      </defs>
    </svg>
    """
  end

  ## JS Commands

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 300,
      transition:
        {"transition-all transform ease-out duration-300",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all transform ease-in duration-200",
         "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-4 sm:translate-y-0 sm:scale-95"}
    )
  end

  def show_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      time: 300,
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide_modal(js \\ %JS{}, id) do
    js
    |> JS.hide(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-in duration-200", "opacity-100", "opacity-0"}
    )
    |> hide("##{id}-container")
    |> JS.hide(to: "##{id}", transition: {"block", "block", "hidden"})
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(JuntosWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(JuntosWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
