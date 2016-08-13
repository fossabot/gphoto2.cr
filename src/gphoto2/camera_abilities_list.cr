require "./struct"

module GPhoto2
  class CameraAbilitiesList
    include Struct(LibGPhoto2::CameraAbilitiesList)

    @context : Context
    @port_info_list : PortInfoList

    def initialize(@context : Context, @port_info_list : PortInfoList = PortInfoList.new)
      new
      load
    end

    def detect : CameraList
      _detect
    end

    def lookup_model(model : String) : Int32
      _lookup_model(model)
    end

    def [](index : Int32) : CameraAbilities
      CameraAbilities.new(self, index)
    end

    # See: `#lookup_model`, `#[]`
    def [](model : String) : CameraAbilities
      index = self.lookup_model(model)
      self[index]
    end

    private def new
      GPhoto2.check! LibGPhoto2.gp_abilities_list_new(out ptr)
      self.ptr = ptr
    end

    private def load
      @context.check! LibGPhoto2.gp_abilities_list_load(self, @context)
    end

    private def _detect
      camera_list = CameraList.new
      @context.check! LibGPhoto2.gp_abilities_list_detect(self, @port_info_list, camera_list, @context)
      camera_list
    end

    private def _lookup_model(model)
      GPhoto2.check! LibGPhoto2.gp_abilities_list_lookup_model(self, model)
    end
  end
end
