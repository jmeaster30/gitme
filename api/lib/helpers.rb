# frozen_string_literal: true

require 'json'
require 'jwt'
require 'sinatra'

helpers do
  def protected!
    return if authorized?

    unauthorized!
  end

  def protected_same_user!(user_name)
    unauthorized! unless authorized?

    @user = Auth.instance.get_user(@user_id)
    return if @user.name == user_name

    unauthorized!
  end

  def unauthorized!
    halt 401, 'Unauthorized ( •̀ω•́ )σ'
  end

  def not_found!
    halt 404, 'Not found ┗(･ω･;)┛'
  end

  def server_error!
    halt 500, 'Something went very wrong ( ✿˃̣̣̥᷄⌓˂̣̣̥᷅ )'
  end

  def make_token(user_id)
    expire_at = Time.now.to_i + ENV['GITME_TOKEN_EXPIRATION'].to_i
    headers = {
      expire_at: expire_at
    }

    @token = JWT.encode({ user_id: user_id }, settings.signing_key, 'RS256', headers)

    {
      expire_at: expire_at,
      access_token: @token,
      token_type: 'Bearer'
    }
  end

  def extract_token
    return request.env['HTTP_AUTHORIZATION']['Bearer '.length..] if request.env['HTTP_AUTHORIZATION']
    return session['access_token'] if session['access_token']
    return cookies['access_token'] if cookies['access_token']

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

      exp = @header['expire_at']

      if exp.nil?
        session['message'] = 'No exp set on JWT token.'
        return false
      end

      @expire_at = Time.at(exp.to_i)

      # make sure the token hasn't expired
      if Time.now > @expire_at
        session['message'] = 'JWT token expired.'
        return false
      end

      @user_id = @payload['user_id']
      true
    rescue JWT::DecodeError => e
      session['message'] = "JWT decode error: #{e.message}"
      false
    end
  end

  def json(data)
    content_type :json
    data.to_json
  end
end
