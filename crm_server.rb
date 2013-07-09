$:<<::File.dirname(__FILE__)

require 'sinatra/base'
require 'savon'
require 'json'
require 'active_support/all'
require 'app/models/init'

class CrmServer < Sinatra::Base

  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'alkdjfheruirgu439ygb34#T^%U^UJergnj3tmsfnvuhr943utnsfnsdjkewq9020923ynfv;jkw'

  MAJOR_VERSION = 0
  MINOR_VERSION = 1
  VERSION_REGEX = %r{/api/v(\d)\.(\d)}

  configure :production, :development do
    enable :logging
    disable :protection
  end

  # configure :production do
  #   use Throttler, :min => 300.0, :cache => Memcached.new, :key_prefix => :throttle
  #   disable :show_exceptions
  # end

  configure do
    # enable :sessions
    # set :session_secret, 'alkdjfheruirgu439ygb34#T^%U^UJergnj3tmsfnvuhr943utnsfnsdjkewq9020923ynfv;jkw'
    set :namespaces, {"xmlns:typ1"  => "http://xmlns.oracle.com/adf/svc/types/"}
  end

  before do
    content_type :json
    # if Sinatra::Base.development?
      response.headers['Access-Control-Allow-Origin'] = '*'
      # response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
      # response.headers['Access-Control-Allow-Headers'] = 'X-CSRF-Token' # This is a Rails header, you may not need it
    # end
  end

  get '/' do
    "App is UP!"
  end

  # ONLY FOR TESTING, PLEASE USE POST IN PROD!!!!!
  get '/logon' do
    session[:ws_host] = params[:ws_host]
    session[:user] = params[:user]
    session[:pwd] = params[:pwd]
    {:status => "ok"}.to_json
  end

  post '/logon' do
    session[:ws_host] = params[:ws_host]
    session[:user] = params[:user]
    session[:pwd] = params[:pwd]
  end

  get '/:lbo' do
    lbo = Object.const_get(params[:lbo].classify).new(settings, session, params)
    response = lbo.find(params, session)
    response.body[("find_#{params[:lbo].singularize}_response").to_sym][:result].to_json
  end

  post '/:lbo' do
    lbo = Object.const_get(params[:lbo].classify).new(settings, session, params)
    response = lbo.add(params, session)
    response.body[("create_#{params[:lbo].singularize}_response").to_sym][:result].to_json
  end

  get '/:lbo/:id' do
    lbo = Object.const_get(params[:lbo].classify).new(settings, session, params)
    response = lbo.get(params, session)
    response.body[("get_#{params[:lbo].singularize}_response").to_sym][:result].to_json
  end

  delete '/:lbo/:id' do
    lbo = Object.const_get(params[:lbo].classify).new(settings, session, params)
    response = lbo.remove(params, session)
    response.body.to_json
  end

  helpers do
    def version_compatible?(nums)
      return MAJOR_VERSION == nums[0].to_i && MINOR_VERSION >= nums[1].to_i
    end
  end

  before VERSION_REGEX do
    if version_compatible?(params[:captures])
      request.path_info = request.path_info.match(VERSION_REGEX).post_match
    else
      halt 400, "Version not compatible with this server"
    end
  end

private
  def responder(r)
    if r.is_a?(Savon::Response)
      yield(r) if block_given?
    else # something went wrong with the SOAP request
      case r[:faultstring]
      when 'Error occurred while processing the query.'
        status 400
      when 'Authentication error. An invalid User Name or Password was entered.'
        status 401
      when 'Invalid session ID'
        status 401
      else
        status 500
      end
      r.to_json
    end
  end

  # start the server if ruby file executed directly
  run! if __FILE__ == $0
end