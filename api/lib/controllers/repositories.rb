# frozen_string_literal: true

require 'fileutils'
require 'sequel'
require 'singleton'
require_relative '../errors'
require_relative '../models/repository'
require_relative '../models/user'

class Repositories
  include Singleton

  def get_repo_by_user_name(user_name, repo_name)
    Repository.association_join(:user).where(Sequel[:user][:name] => user_name).where(name: repo_name).qualify.first!
  rescue Sequel::NoMatchingRow
    raise NotFoundError.new("Repo '#{repo_name}' from '#{user_name}' not found")
  end

  def get_repos_by_user(user_name)
    User.where(name: user_name).first!
  rescue Sequel::NoMatchingRow
    raise NotFoundError.new("User '#{user_name}' not found")
  end

  def create_repo(user, body)
    repo_path = "#{ENV[GITME_REPOSITORY_FOLDER]}/#{user.name}/#{body[:name]}.git"
    FileUtils.mkdir_p repo_path
    repo = Repository.new(user_id: user.id, created_at: DateTime.now)
    repo.name = body[:name]
    repo.path = repo_path
    repo.save
  rescue Sequel::UniqueConstraintViolation
    raise ValidationError.new("User '#{user.name}' already has repo '#{body[:name]}'")
  end

  def update_repo(user, body)
    repo = Repository[body[:id]]
    raise NotFoundError.new("Repo id '#{body[:id]}' not found") if repo.nil?

    repo.name = body[:name]
    repo.save
  rescue Sequel::UniqueConstraintViolation
    raise ValidationError.new("User '#{user.name}' already has repo '#{body[:name]}'")
  end
end
