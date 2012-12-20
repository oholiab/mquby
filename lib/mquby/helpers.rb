class String
  def to_sizeinbytes
    case self
    when /^(\d+)GB$/
      return $1.to_i * (1024^3)
    when /^(\d+)MB$/
      return $1.to_i * (1024^2)
    when /^(\d+)kB$/
      return $1.to_i * 1024
    when /^(\d+)B$/
      return $1.to_i
    end
    raise TypeError "Argument to to_bytes method must be a string consisting of an integer suffixed with GB, MB or B with no surrounding whitespace"
  end
end
