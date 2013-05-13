require_relative '../../lib/pageable'

class FindCriteria
  include Pageable

	def initialize(ns = "typ1", params = {}, max_fetch_size)
		@ns = ns
		@params = params
    @max_fetch_size = max_fetch_size
	end

	def to_s
    xml_builder = Builder::XmlMarkup.new
    xml_builder.types :findCriteria do |xml|
      xml.tag!("#{@ns}:fetchStart", fetch_start(@params[:page], @params[:page_size]||@max_fetch_size))
      xml.tag!("#{@ns}:fetchSize", fetch_size(@params[:page_size]||@max_fetch_size))
      filter(@params[:search], xml) if @params[:search]
      sort_order(@params[:sort], xml) if @params[:sort]
    end
	end

  def filter(where, xml)
    xml.tag! "#{@ns}:filter" do |xml1|
      xml1.tag! "#{@ns}:group" do |xml2|
        where.each do |a, v|
          add_filter(a, v, xml2)
        end if where
      end
    end
  end

  def add_filter(a, v, xml, o='=')
    xml.tag! "#{@ns}:item" do |x|
      x.tag! "#{@ns}:conjunction", "And" # Hard Coded ... for now
      x.tag! "#{@ns}:upperCaseCompare", true # Hard Coded ... for now
      x.tag! "#{@ns}:attribute", a
      x.tag! "#{@ns}:operator", o # Hard Coded ... for now
      x.tag! "#{@ns}:value", v
    end
  end

  def sort_order(sort, xml)
    if sort
      xml.tag! "#{@ns}:sortOrder" do |xml1|
        sort.each do |a, v|
          xml1.tag! "#{@ns}:sortAttribute" do |x|
            x.tag! "#{@ns}:name", a
            x.tag! "#{@ns}:descending", v=="asc" ? false : true
          end
        end
      end
    end
  end
end