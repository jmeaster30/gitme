# frozen_string_literal: true

require 'bcrypt'
require 'sequel'
require 'singleton'

require_relative '../models/user'

# Handles all functionality around creating, editing, and authenticating users
class Auth
  include Singleton

  def get_user_by_creds(username, password)
    user = User.first(name: username)
    return if user.nil?

    return user if BCrypt::Password.new(user.password) == password

    nil
  end

  def get_user(user_id)
    User[user_id]
  end

  def generate_password_hashsalt(user, new_password)
    user.password = BCrypt::Password.create(new_password)
  end

  def create_user(body)
    user = User.new(created_at: DateTime.now)
    user.name = body[:name]
    raise ValidationError, 'A password is required pls' if body[:password].nil?

    user.password = BCrypt::Password.create(body[:password])

    user.save
    user
  rescue Sequel::UniqueConstraintViolation
    raise ValidationError, "Username '#{user.name}' already exists."
  end

  def update_user(body)
    user = User[body[:id]]
    raise NotFoundError, "User id '#{body[:id]}' not found" if user.nil?

    user.name = body[:name]
    user.password = BCrypt::Password.create(body[:password]) unless body[:password].nil?
    user.save
    user
  rescue Sequel::UniqueConstraintViolation
    raise ValidationError, "Username '#{user.name}' already exists."
  end
end
