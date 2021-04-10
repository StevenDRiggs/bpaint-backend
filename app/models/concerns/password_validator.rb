class PasswordValidator < ActiveModel::EachValidator
  def validate_each(instance, attr, value)
    if value.nil? || value.length < 2
      instance.errors.add attr, 'must be at least 1 character long'
    end

    unless value != instance.username
      instance.errors.add attr, 'must not be the same as username'
    end
  end
end
