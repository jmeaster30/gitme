# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'jsonable'

class Repository < Sequel::Model(:repository)
  include JSONable

  many_to_one :user

  def with_owner
    default_view = base_view
    default_view[:owner] = user
    default_view
  end

  def default_view
    with_owner
  end
end
