# frozen_string_literal: true

module JSONable
  def base_view
    hash = {}
    self.values.each do |key, value|
      hash[key] = value
    end
    hash
  end

  def default_view
    self.base_view
  end

  def to_json
    self.default_view.to_json
  end
end