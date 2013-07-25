$:<<::File.dirname(__FILE__)

require 'savon'
require 'find_criteria'

class SalesParty
  extend Savon::Model

  # attr_accessor :max_fetch_size

  def initialize(settings, session, params)
    @max_fetch_size = 20
    @lbo_name = self.class.name.underscore
    self.class.operations "find_#{@lbo_name}".to_sym,
                          "get_#{@lbo_name}".to_sym,
                          # "delete_#{@lbo_name}".to_sym,
                          "create_#{@lbo_name}".to_sym
    self.class.client wsdl: "#{session[:ws_host]||params[:ws_host]}/crmCommonSalesParties/SalesPartyService?wsdl",
           ssl_verify_mode: :none
    self.class.global :basic_auth, session[:user]||params[:user], session[:pwd]||params[:pwd]
    self.class.global :namespaces, settings.namespaces.merge({
      "xmlns:types"          => "http://xmlns.oracle.com/apps/crmCommon/salesParties/salesPartiesService/types/",
      "xmlns:#{@lbo_name}"   => "http://xmlns.oracle.com/apps/crmCommon/salesParties/salesPartiesService/"
    })
  end

  def find_sales_party(params, session)
    super(message: FindCriteria.new("typ1", params, @max_fetch_size))
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :find :find_sales_party

  def get_sales_party(params, session)
    super(message: {"types:partyId" => params[:id]})
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :get :get_sales_party

# Haven't figured out the parameters yet
  # def create_sales_party(params, session)
  #   super(message: {
  #     "types:#{@lbo_name}" => {
  #       "#{@lbo_name}:Name" => params[:name],
  #       "#{@lbo_name}:Description" => params[:description]
  #     }
  #   })
  # rescue Savon::SOAPFault => error
  #   error.to_hash[:fault]
  # end
  # alias :add :create_opportunity

  # Oppertion does not exist in wsdl.
  # def delete_sales_party(params, session)
  # end
  # alias :remove :delete_opportunity

end