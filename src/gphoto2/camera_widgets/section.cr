require "./base"

module GPhoto2
  class CameraWidget
    class Section < Base
      protected def get_value
        raise NotImplementedError.new
      end

      protected def set_value(value)
        raise NotImplementedError.new
      end
    end
  end
end
