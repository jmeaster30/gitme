# frozen_string_literal: true

require 'singleton'
require_relative '../models/repository'
require_relative '../models/user'

class Repositories
  include Singleton

  def get_repo_by_user_name(user, repo_name)
    Repository.association_join(:user).where(Sequel[:user][:name] => user).where(name: repo_name).qualify.first!
  end
  
  def get_repos_by_user(user)
    User.where(name: user).first!
  end
end
