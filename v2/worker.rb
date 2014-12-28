class Worker < Unit
  RESOURCE = 40.freeze

  def build_village?(map)
    near_resources = map.near_resources(y, x)
    return false if near_resources.size <= 0

    near_resources.all? do |resource|
      map.near_villages(resource.y, resource.x).size <= 0
    end
  end

  def create_base(map)
    if map.at(y, x).bases.size <= 0
      self.action = :create_base
    end
  end
end
