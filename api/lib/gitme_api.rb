# frozen_string_literal: true

require 'dotenv/load'
require 'json'
require 'openssl'
require 'sequel'
require 'sinatra'
require 'sinatra/cookies'

Database = Sequel.connect('sqlite://gitme.db')

require_relative 'controllers/repositories'
require_relative 'controllers/auth'
require_relative 'errors'
require_relative 'helpers'

def read_key(key_sym, env_var)
  path = File.expand_path ENV[env_var]
  key = OpenSSL::PKey::RSA.new File.read path
  set key_sym, key
end

read_key :signing_key, 'GITME_SIGNING_KEY'
read_key :verify_key,  'GITME_VERIFY_KEY'

enable :sessions
set :session_secret, ENV['GITME_SESSION_SECRET']
set :show_exceptions, false

before do
  puts 'oooo'
  if request.body.size > 0
    puts 'body has stuff'
    request.body.rewind
    @request_payload = JSON.parse(request.body.read, symbolize_names: true)
  end
end

post '/api/token' do
  username = @request_payload[:username]
  password = @request_payload[:password]
  found_user = Auth.instance.get_user_by_creds(username, password)
  unauthorized! if found_user.nil?

  expire_at = make_token found_user.id
  json 'expire_at' => expire_at
end

get '/api/repo/:user' do |user|
  protected!
  json Repositories.instance.get_repos_by_user(user)
end

put '/api/repo/:user' do |user|
  protected_same_user! user
  json Repositories.instance.create_repo(@user, @request_payload)
end

post '/api/repo/:user' do |user|
  protected_same_user! user
  json Repositories.instance.update_repo(@user, @request_payload)
end

get '/api/repo/:user/:repo_name' do |user, repo_name|
  protected!
  json Repositories.instance.get_repo_by_user_name(user, repo_name)
end

put '/api/user' do
  puts @request_payload
  protected!
  json Auth.instance.create_user(@request_payload)
end

post '/api/user' do
  user = Auth.instance.get_user @request_payload[:id]
  raise NotFoundError.new("User id #{@request_payload[:id]} doesn't exist") if user.nil?

  protected_same_user! user.name
  json Auth.instance.update_user(@request_payload)
end

# get /\/([_a-zA-Z0-9]+)\/([_a-zA-Z0-9]+)\.git/ do |user_name, repo_name|
#  protected!
#  send_file
# end

not_found do
  not_found!
end

error Sequel::NoMatchingRow do
  not_found!
end

error HttpError do
  @error = env['sinatra.error']
  halt @error.statuscode, @error.message
end

error do
  server_error!
end
