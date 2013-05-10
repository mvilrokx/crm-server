$:<<::File.dirname(__FILE__)

require 'sinatra/base'
require 'savon'
require 'json'

require 'app/models/interaction'

class CrmServer < Sinatra::Base


  MAJOR_VERSION = 0
  MINOR_VERSION = 1
  VERSION_REGEX = %r{/api/v(\d)\.(\d)}

  configure :production, :development do
    enable :logging
    disable :protection
  end

  # configure :production do
  #   use Throttler, :min => 300.0, :cache => Memcached.new, :key_prefix => :throttle
  # 	disable :show_exceptions
  # end

	configure do
		enable :sessions
		set :session_secret, 'alkdjfheruirgu439ygb34#T^%U^UJergnj3tmsfnvuhr943utnsfnsdjkewq9020923ynfv;jkw'
	  set :ws_host, 'https://fap0581-crm.oracleads.com'
	  set :user => 'lisa.jones', :pwd => 'Ngt49384' # 'BGG58595'
	  set :views, settings.root + '/app/views'
	end

	before do
		content_type :json
	end

	get '/interactions' do
		response = Interaction.find_interaction(params, session)
		response.body[("find_interaction_response").to_sym][:result].to_json

		# "hello world"
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