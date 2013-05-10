$:<<::File.dirname(__FILE__)

require 'crm_server'

map "/" do
  run CrmServer
end