defmodule Juntos.Events.Uploaders.CoverImageTest do
  use ExUnit.Case, async: true
  alias Juntos.Events.Uploaders.CoverImage, as: SUT

  describe "transform/2" do
    test "test uploading jpg and converting to web" do
      image_path = "test/assets/event-cover-01.jpg"
      file = new_waffle_file(image_path)

      assert {transform_fn, _} = SUT.transform(:webp400x400, {file, nil})

      assert {:ok, file} = transform_fn.(:webp400x400, %Waffle.File{path: image_path})
      assert file.path =~ ".webp"
    end

    test "test uploading gif and keep it as it is" do
      image_path = "test/assets/event-cover-supercat-02.gif"
      file = new_waffle_file(image_path)

      assert {transform_fn, _} =
               SUT.transform(
                 :webp400x400,
                 {file, nil}
               )

      assert {:ok, file} = transform_fn.(:webp400x400, file)
      assert file.path =~ ".gif"
    end
  end

  defp new_waffle_file(file_path) do
    %Waffle.File{path: file_path, file_name: Path.basename(file_path)}
  end
end
