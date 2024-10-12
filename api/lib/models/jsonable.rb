# frozen_string_literal: true

module JSONable
  def base_view
    hash = {}
    values.each do |key, value|
      hash[key] = value
    end
    hash
  end

  def default_view
    base_view
  end

  def to_json(*_args)
    default_view.to_json
  end
end
