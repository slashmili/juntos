defmodule Storybook.CoreComponents do
  use PhoenixStorybook.Index

  def folder_open?, do: true

  def entry("back"), do: [icon: {:fa, "circle-left", :thin}]
  def entry("hero"), do: [icon: {:fa, "heading", :thin}]
  def entry("button"), do: [icon: {:fa, "rectangle-ad", :thin}]
  def entry("error"), do: [icon: {:fa, "circle-exclamation", :thin}]
  def entry("flash"), do: [icon: {:fa, "bolt", :thin}]
  def entry("header"), do: [icon: {:fa, "heading", :thin}]
  def entry("icon"), do: [icon: {:fa, "icons", :thin}]
  def entry("input"), do: [icon: {:fa, "input-text", :thin}]
  def entry("list"), do: [icon: {:fa, "list", :thin}]
  def entry("table"), do: [icon: {:fa, "table", :thin}]

  def entry("navbar"),
    do: [icon: {:local, "hero-bars-2", "psb-w-5 psp-h-5"}]

  def entry("content_text"),
    do: [icon: {:local, "hero-document-text", "psb-w-5 psp-h-5"}]

  def entry("bottom_sheet"),
    do: [icon: {:local, "hero-document-arrow-up", "psb-w-5 psp-h-5"}]
end
