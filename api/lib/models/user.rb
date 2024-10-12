# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'jsonable'

class User < Sequel::Model(:user)
  include JSONable

  one_to_many :repository

  def with_repositories
    default_view = base_view
    default_view[:repositories] = repository.map { |repo| repo.base_view }
    default_view
  end

  def default_view
    with_repositories
  end
end
