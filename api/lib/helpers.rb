# frozen_string_literal: true

require 'json'
require 'jwt'
require 'sinatra'

helpers do
  def protected!
    return if authorized?

    unauthorized!
  end

  def unauthorized!
    halt 401, 'Unauthorized'
  end

  def make_token(user_id)
    expire_at = Time.now.to_i + ENV['GITME_TOKEN_EXPIRATION'].to_i
    headers = {
      expire_at: expire_at
    }

    @token = JWT.encode({ user_id: user_id }, settings.signing_key, 'RS256', headers)

    session['access_token'] = @token
    expire_at
  end

  def extract_token
    return request.env['access_token'] if request.env['access_token']
    # return request.access_token if request.access_token
    return session['access_token'] if session['access_token']

    nil
  end

  def authorized?
    @token = extract_token

    if @token.nil?
      session['message'] = 'No JWT found in session.  Please log in.'
      return false
    end

    begin
      @payload, @header = JWT.decode(@token, settings.verify_key, true, { algorithm: 'RS256' })

      @exp = @header['expire_at']

      # check to see if the exp is set (we don't accept forever tokens)
      if @exp.nil?
        session['message'] = 'No exp set on JWT token.'
        return false
      end

      @exp = Time.at(@exp.to_i)

      # make sure the token hasn't expired
      if Time.now > @exp
        session['message'] = 'JWT token expired.'
        return false
      end

      @user_id = @payload['user_id']
    rescue JWT::DecodeError => e
      session['message'] = "JWT decode error: #{e.message}"
      false
    end
  end

  def json(data)
    content_type :json
    data.to_json
  end

  def get_request_body
    puts request.instance_variables
    request.body.rewind
    JSON.parse request.body.read
  end
end
