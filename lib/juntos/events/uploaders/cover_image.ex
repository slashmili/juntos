defmodule Juntos.Events.Uploaders.CoverImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original, :jpg400x400, :webp400x400]

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(~w(.jpg .jpeg .gif .png .webp), file_extension) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  def transform(version, {%{file_name: file_name}, _} = details)
      when version in [:jpg400x400, :webp400x400] do
    if String.downcase(file_name) =~ ".gif" do
      transform_gif(version, details)
    else
      transform_other_fomrats(version, details)
    end
  end

  defp transform_gif(_version, _details) do
    ext = "gif"

    process = fn _version, file ->
      original_raw = File.read!(file.path)
      {:ok, original} = Image.from_binary(original_raw)

      {:ok, thumbnail} = Image.thumbnail(original, 400, crop: :attention)
      tmp_path = Waffle.File.generate_temporary_path(ext)
      Image.write(thumbnail, tmp_path)

      {:ok, %Waffle.File{file | path: tmp_path, is_tempfile?: true}}
    end

    {process, fn _, _ -> "#{ext}" end}
  end

  defp transform_other_fomrats(version, _) do
    ext =
      case version do
        :jpg400x400 -> "jpg"
        :webp400x400 -> "webp"
      end

    process = fn _version, file ->
      original_raw = File.read!(file.path)
      {:ok, original} = Image.from_binary(original_raw)

      {:ok, thumbnail} = Image.thumbnail(original, 400, crop: :attention)
      tmp_path = Waffle.File.generate_temporary_path(ext)
      Image.write(thumbnail, tmp_path)

      {:ok, %Waffle.File{file | path: tmp_path, is_tempfile?: true}}
    end

    {process, fn _, _ -> ext end}
  end

  def filename(version, _) do
    version
  end

  def storage_dir(_version, {_file, event}) do
    "uploads/events/cover/#{event.id}"
  end
end
