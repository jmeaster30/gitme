# frozen_string_literal: true

require 'json'
require 'sequel'

require_relative 'jsonable'

class User < Sequel::Model(:user)
  include JSONable

  one_to_many :repository

  def without_password(base)
    base.delete(:password)
    base
  end

  def with_repositories(base)
    base[:repositories] = repository.map { |repo| repo.with_base }
    base
  end

  def default_view
    view(:without_password, :with_repositories)
  end
end
