defmodule Storybook.EventComponents do
  use PhoenixStorybook.Index

  def folder_open?, do: false

  def entry("datepicker"), do: [icon: {:local, "hero-calendar-days", "psb-w-5 psp-h-5"}]

  def entry("location_finder"),
    do: [icon: {:local, "hero-magnifying-glass-circle", "psb-w-5 psp-h-5"}]
end
