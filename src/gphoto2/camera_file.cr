require "./struct"

module GPhoto2
  class CameraFile
    include GPhoto2::Struct(LibGPhoto2::CameraFile)

    # The preview data is assumed to be a jpg.
    PREVIEW_FILENAME = "capture_preview.jpg"

    getter! folder : String?
    getter! name : String?

    @camera : Camera
    @data_and_size : Tuple(LibC::Char*, LibC::ULong)?

    def initialize(@camera : Camera, @folder : String? = nil, @name : String? = nil)
      new
    end

    def close : Void
      free
    end

    def preview?
      !(@folder && @name)
    end

    def save(pathname : String = default_filename) : Void
      unless Dir.exists? pathname
        Dir.mkdir_p File.dirname(pathname)
      end
      File.open pathname, "w", &.write(to_slice)
    end

    def delete : Void
      @camera.delete(self)
    end

    def data : LibC::Char*
      data_and_size.first
    end

    def size : LibC::ULong
      data_and_size.last
    end

    def to_slice : Slice(LibC::Char)
      data.to_slice(size)
    end

    def info : CameraFileInfo?
      preview? ? nil : get_info
    end

    def extname : String
      File.extname(name)[1..-1].downcase
    end

    def_equals @camera, @folder, @name

    private def new
      GPhoto2.check! LibGPhoto2.gp_file_new(out ptr)
      self.ptr = ptr
    end

    private def free
      GPhoto2.check! LibGPhoto2.gp_file_free(self)
      self.ptr = nil
    end

    private def default_filename
      preview? ? PREVIEW_FILENAME : name
    end

    private def data_and_size
      @data_and_size ||= begin
        @camera.file(self) unless preview?
        get_data_and_size
      end
    end

    private def get_data_and_size
      GPhoto2.check! LibGPhoto2.gp_file_get_data_and_size(self, out data, out size)
      {data, size}
    end

    private def get_info
      GPhoto2.check! LibGPhoto2.gp_camera_file_get_info(@camera, folder, name, out info, @camera.context)
      CameraFileInfo.new info
    end
  end
end
