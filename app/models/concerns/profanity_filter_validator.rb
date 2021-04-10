class ProfanityFilterValidator < ActiveModel::EachValidator
  def validate_each(instance, attr, value)
    if ProfanityFilter.new.profane?(value, strategies: :all)
      instance.errors.add attr, 'cannot include profanity'
    end
  end
end
