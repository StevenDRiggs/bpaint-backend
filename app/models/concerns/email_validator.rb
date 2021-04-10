class EmailValidator < ActiveModel::EachValidator
  def validate_each(instance, attr, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      instance.errors.add attr, 'is not a valid email'
    end
  end
end
