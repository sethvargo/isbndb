class Symbol
  def titleize
    self.to_s.titleize
  end

  def underscore
    self.to_s.underscore.to_sym
  end
end
