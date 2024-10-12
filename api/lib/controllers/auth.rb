# frozen_string_literal: true

require 'singleton'

require_relative '../models/user'

class Auth
  include Singleton

  def get_user_by_creds(username, password)
    # FIXME: should use a salt and repeated hash of the password for better security
    User.where(name: username, password: password).first
  end
end
