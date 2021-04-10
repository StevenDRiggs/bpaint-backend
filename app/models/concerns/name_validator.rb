class NameValidator < ActiveModel::EachValidator
  def validate_each(instance, attr, value)
    unless value.length >= 2
      instance.errors.add attr, 'must be at least 2 characters long'
    end
  end
end
