# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'jsonable'

class Repository < Sequel::Model(:repository)
  include JSONable

  many_to_one :user

  def with_owner(base)
    base[:owner] = user.view(:without_password)
    base
  end

  def default_view
    view(:with_owner)
  end
end
