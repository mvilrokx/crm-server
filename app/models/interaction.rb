$:<<::File.dirname(__FILE__)

require 'savon'
require 'queryable'

class Interaction
  extend Savon::Model
  include Queryable

  @max_fetch_size = 1

  def initialize(settings, session)
    self.class.operations :find_interaction
    self.class.client wsdl: "#{session[:ws_host]}/appCmmnCompInteractions/InteractionService?wsdl",
           ssl_verify_mode: :none
    self.class.global :basic_auth, session[:user], session[:pwd]
    self.class.global :namespaces, settings.namespaces.merge({
      "xmlns:types" => "http://xmlns.oracle.com/apps/crmCommon/interactions/interactionService/types/"
    })
  end

  def find_interaction(params, session)
    super(message: find_criteria)
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end

end