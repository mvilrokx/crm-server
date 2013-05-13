$:<<::File.dirname(__FILE__)

require 'savon'
require 'find_criteria'

class Interaction
  extend Savon::Model

  # attr_accessor :max_fetch_size

  def initialize(settings, session)
    @max_fetch_size = 1
    # self.class.operations "find_#{self.name.underscore}".to_sym
    self.class.operations "find_interaction".to_sym,
                          "get_interaction".to_sym,
                          "delete_interaction".to_sym,
                          "create_interaction".to_sym
    self.class.client wsdl: "#{session[:ws_host]}/appCmmnCompInteractions/InteractionService?wsdl",
           ssl_verify_mode: :none
    self.class.global :basic_auth, session[:user], session[:pwd]
    self.class.global :namespaces, settings.namespaces.merge({
      "xmlns:types" => "http://xmlns.oracle.com/apps/crmCommon/interactions/interactionService/types/",
      "xmlns:int" => "http://xmlns.oracle.com/apps/crmCommon/interactions/interactionService/"
    })
  end

  def find_interaction(params, session)
    super(message: FindCriteria.new("typ1", params, @max_fetch_size)) #criteria)
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

  def create_interaction(params, session)
    super(message: {
      "types:interaction" => {
        "int:InteractionStartDate" => params[:interaction_start_date],
        "int:InteractionEndDate" => params[:interaction_end_date] || nil,
        # "int:CustomerId",
        "int:InteractionDescription" => params[:interaction_description],
        # "int:OutcomeCode",
        "int:InteractionTypeCode" => params[:interaction_type_code] || "PHONE CALL",
        "int:DirectionCode" => params[:direction_code] || "OUTBOUND",
        # THIS MAKES OPPORTUNITY MANDATORY!!!
        "int:InteractionAssociation" => {
          "int:AssociatedObjectUid" => params[:opportunity_id],
          "int:AssociatedObjectCode" => "OPPORTUNITY",
          "int:ActionCode" => "CREATED"
        }
      }
    })
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :add :create_interaction

  def delete_interaction(params, session)
    super(message: {
      "types:interaction" => {
        "int:InteractionId" => params[:id]}
    })
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :remove :delete_interaction

end