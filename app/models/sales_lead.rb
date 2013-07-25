$:<<::File.dirname(__FILE__)

require 'savon'
require 'find_criteria'

class SalesLead
  extend Savon::Model

  def initialize(settings, session, params)
    @max_fetch_size = 20
    @lbo_name = self.class.name.underscore
    puts @lbo_name
    self.class.operations "find_#{@lbo_name}".to_sym,
                          "get_#{@lbo_name}".to_sym,
                          "delete_#{@lbo_name}".to_sym,
                          "create_#{@lbo_name}".to_sym
    self.class.client wsdl: "#{session[:ws_host]||params[:ws_host]}/mklLeads/SalesLeadService?wsdl",
           ssl_verify_mode: :none
    self.class.global :basic_auth, session[:user]||params[:user], session[:pwd]||params[:pwd]
    self.class.global :namespaces, settings.namespaces.merge({
      "xmlns:types"        => "http://xmlns.oracle.com/apps/marketing/leadMgmt/leads/leadService/types/",
      "xmlns:#{@lbo_name}" => "http://xmlns.oracle.com/apps/marketing/leadMgmt/leads/leadService/"
    })
  end

  def find_sales_lead(params, session)
    super(message: FindCriteria.new("typ1", params, @max_fetch_size)) #criteria)
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :find :find_sales_lead

  def get_sales_lead(params, session)
    super(message: {"types:leadId" => params[:id]})
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :get :get_sales_lead

  def create_sales_lead(params, session)
    super(message: {
      "types:#{@lbo_name}" => {
        "#{@lbo_name}:Name" => params[:name],
        "#{@lbo_name}:Rank" => params[:rank]
      }
    })
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :add :create_sales_lead

  def delete_sales_lead(params, session)
    super(message: {
      "types:#{@lbo_name}" => {
        "#{@lbo_name}:LeadId" => params[:id]}
    })
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :remove :delete_sales_lead

end