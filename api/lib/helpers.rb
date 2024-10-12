# frozen_string_literal: true

require 'json'
require 'sinatra'

helpers do
  def protected!
    return if authorized?
    halt 401, "Unauthorized"
  end

  def json data
    content_type :json
    data.to_json
  end
end