class String
  def is_plural?
    self.downcase.pluralize == self.downcase
  end

  def is_singular?
    !self.is_plural?
  end
end
