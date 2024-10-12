# frozen_string_literal: true

require 'json'
require 'sequel'
require 'sinatra'

Database = Sequel.connect('sqlite://gitme.db')

require_relative 'controllers/repositories'

require_relative 'helpers'

#use Rack::Auth::Basic, "Authorization Required" do |user, pass|
  # Perform some kind of check and return true/false
  #Users.instance.authenticated?(user, pass)
#end

get '/:user' do |user|
  json Repositories.instance.get_repos_by_user(user)
end

get '/:user/:repo_name' do |user, repo_name|
  json Repositories.instance.get_repo_by_user_name(user, repo_name)
end



