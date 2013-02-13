class String
  require 'date'

  def titleize
    str = self[0].upcase + self[1..-1].downcase
  end

  def singularize
    str = self.dup
    if str[-3..-1] == 'ies'
      str[0..-4] + 'y'
    elsif str[-1] == 's'
      str[0..-2]
    else
      str
    end
  end

  def pluralize
    str = self.dup
    if str[-1] == 'y'
      str[0..-2] + 'ies'
    elsif str[-1] == 's'
      str
    else
      str + 's'
    end
  end

  def blank?
    dup.strip.length == 0 ? true : false
  end

  def underscore
    self.dup.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end
