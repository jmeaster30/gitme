# frozen_string_literal: true

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

  def to_json(*_args)
    default_view.to_json(*_args)
  end
end
