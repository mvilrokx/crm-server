$:<<::File.dirname(__FILE__)

require 'savon'
require 'find_criteria'

class Opportunity
  extend Savon::Model

  # attr_accessor :max_fetch_size

  def initialize(settings, session)
    @max_fetch_size = 10
    @lbo_name = self.class.name.snakecase
    self.class.operations "find_#{@lbo_name}".to_sym,
                          "get_#{@lbo_name}".to_sym,
                          "delete_#{@lbo_name}".to_sym,
                          "create_#{@lbo_name}".to_sym
    self.class.client wsdl: "#{session[:ws_host]}/opptyMgmtOpportunities/OpportunityService?wsdl",
           ssl_verify_mode: :none
    self.class.global :basic_auth, session[:user], session[:pwd]
    self.class.global :namespaces, settings.namespaces.merge({
      "xmlns:types" => "http://xmlns.oracle.com/apps/sales/opptyMgmt/opportunities/opportunityService/types/",
      "xmlns:#{@lbo_name}"   => "http://xmlns.oracle.com/apps/sales/opptyMgmt/opportunities/opportunityService/"
    })
  end

  # I can't get this to work, but it should so it becomes generic
  # define_method("find_#{@lbo_name}") do |params, session|
  #   super(message: FindCriteria.new("typ1", params, @max_fetch_size))
  #   alias_method :find, :find_opportunity
  # end
  # alias :find :find_opportunity

  def find_opportunity(params, session)
    super(message: FindCriteria.new("typ1", params, @max_fetch_size)) #criteria)
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :find :find_opportunity

  def get_opportunity(params, session)
    super(message: {"types:optyId" => params[:id]})
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :get :get_opportunity

  def create_opportunity(params, session)
    super(message: {
      "types:#{@lbo_name}" => {
        "#{@lbo_name}:Name" => params[:name],
        "#{@lbo_name}:Description" => params[:description]
      }
    })
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :add :create_opportunity

  def delete_opportunity(params, session)
    super(message: {
      "types:#{@lbo_name}" => {
        "#{@lbo_name}:OptyId" => params[:id]}
    })
  rescue Savon::SOAPFault => error
    error.to_hash[:fault]
  end
  alias :remove :delete_opportunity

end