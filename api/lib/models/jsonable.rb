# frozen_string_literal: true

# Can be included for our database models so that they can be converted to hash tables and serialized into json
# Also allows defining custom views to hide variables that aren't needed
module JSONable
  def with_base
    hash = {}
    values.each do |key, value|
      hash[key] = value
    end
    hash
  end

  def default_view
    view(:with_base)
  end

  def view(*views)
    base = with_base
    views.each do |v|
      base = send(v, base)
    end
    base
  end

  def to_json(*args)
    default_view.to_json(*args)
  end
end
