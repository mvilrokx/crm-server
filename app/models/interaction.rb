$:<<::File.dirname(__FILE__)

require 'savon'
require 'queryable'

class Interaction
  extend Savon::Model
  include Queryable

  @max_fetch_size = 1

  operations :find_interaction
  client       wsdl: "https://fap0581-crm.oracleads.com/appCmmnCompInteractions/InteractionService?wsdl",
    ssl_verify_mode: :none
  # global :basic_auth, settings.user, settings.pwd
  global :basic_auth, 'lisa.jones', 'Ngt49384'
  global :namespaces, {
    "xmlns:types" => "http://xmlns.oracle.com/apps/crmCommon/interactions/interactionService/types/",
    "xmlns:typ1"  => "http://xmlns.oracle.com/adf/svc/types/"
  }

  def self.find_interaction(params, session)
    super(message: find_criteria)
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end

end