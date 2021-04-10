class UrlValidator < ActiveModel::EachValidator
  def validate_each(instance, attr, value)
    unless value =~ /https?:\/\/(www\.)?.*\..*/
      instance.errors.add attr, 'is not a valid url'
    end
  end
end
