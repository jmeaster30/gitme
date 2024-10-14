# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'jsonable'

# Model for the 'user' table in sqlite
class User < Sequel::Model(:user)
  include JSONable

  one_to_many :repository

  def without_password(base)
    base.delete(:password)
    base
  end

  def with_repositories(base)
    base[:repositories] = repository.map(&:with_base)
    base
  end

  def default_view
    view(:without_password, :with_repositories)
  end
end
