$:<<::File.dirname(__FILE__)

require 'savon'
require 'find_criteria'

class Interaction
  extend Savon::Model

  def initialize(settings, session)
    @max_fetch_size = 1
    # self.class.operations "find_#{self.name.underscore}".to_sym
    self.class.operations "find_interaction".to_sym, "get_interaction".to_sym
    self.class.client wsdl: "#{session[:ws_host]}/appCmmnCompInteractions/InteractionService?wsdl",
           ssl_verify_mode: :none
    self.class.global :basic_auth, session[:user], session[:pwd]
    self.class.global :namespaces, settings.namespaces.merge({
      "xmlns:types" => "http://xmlns.oracle.com/apps/crmCommon/interactions/interactionService/types/"
    })
  end

  def find_interaction(params, session)
    super(message: FindCriteria.new("typ1", params)) #criteria)
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :find :find_interaction

  def get_interaction(params, session)
    super(message: {"types:interactionId" => params[:id]})
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :get :get_interaction

end