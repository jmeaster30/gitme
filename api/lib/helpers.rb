# frozen_string_literal: true

require 'json'
require 'jwt'
require 'sinatra'

# Short circuiting helpers
helpers do
  def unauthorized!
    halt 401, 'Unauthorized ( •̀ω•́ )σ'
  end

  def not_found!
    halt 404, 'Not found ┗(･ω･;)┛'
  end

  def server_error!
    halt 500, 'Something went very wrong ( ✿˃̣̣̥᷄⌓˂̣̣̥᷅ )'
  end
end

# data fixing helpers
helpers do
  def json(data)
    content_type :json
    data.to_json
  end
end

# dealing creating and getting tokens
helpers do
  def make_token(user_id)
    expire_at = Time.now.to_i + ENV['GITME_TOKEN_EXPIRATION'].to_i
    headers = {
      expire_at: expire_at
    }

    @token = JWT.encode({ user_id: user_id }, settings.signing_key, 'RS256', headers)
    session['access_token'] = @token

    {
      expire_at: expire_at,
      access_token: @token,
      token_type: 'Bearer'
    }
  end

  def extract_token!
    return request.env['HTTP_AUTHORIZATION']['Bearer '.length..] if request.env['HTTP_AUTHORIZATION']
    return session['access_token'] if session['access_token']

    unauthorized!
  end
end

# authorization checks
helpers do
  def require_header_field!(field_name)
    value = @header[field_name]
    return value if value

    unauthorized!
  end

  def check_authorized!
    @token = extract_token!

    begin
      @payload, @header = JWT.decode(@token, settings.verify_key, true, { algorithm: 'RS256' })

      exp = require_header_field! 'expire_at'

      @expire_at = Time.at(exp.to_i)
      unauthorized! if Time.now > @expire_at

      @user_id = @payload['user_id']
    rescue JWT::DecodeError
      unauthorized!
    end
  end

  def check_authorized_same_user!(user_name)
    check_authorized!

    @user = Auth.instance.get_user(@user_id)
    return if @user.name == user_name

    unauthorized!
  end
end
