# frozen_string_literal: true

require 'dotenv/load'
require 'json'
require 'openssl'
require 'sequel'
require 'sinatra'

Database = Sequel.connect('sqlite://gitme.db')

require_relative 'controllers/repositories'
require_relative 'controllers/auth'

require_relative 'helpers'

def read_key(key_sym, env_var)
  path = File.expand_path ENV[env_var]
  key = OpenSSL::PKey::RSA.new File.read path
  set key_sym, key
end

read_key :signing_key, 'GITME_SIGNING_KEY'
read_key :verify_key,  'GITME_VERIFY_KEY'

enable :sessions

post '/api/token' do
  username = request.params['username'] # FIXME: This doesn't need to be in the body but it wouldn't hurt
  password = request.params['password'] # FIXME: This NEEDS to be in the post request body
  found_user = Auth.instance.get_user_by_creds(username, password)
  unauthorized! if found_user.nil?

  expire_at = make_token found_user.id
  json 'expire_at' => expire_at
end

get '/api/:user' do |user|
  protected!
  json Repositories.instance.get_repos_by_user(user)
end

get '/api/:user/:repo_name' do |user, repo_name|
  protected!
  json Repositories.instance.get_repo_by_user_name(user, repo_name)
end
