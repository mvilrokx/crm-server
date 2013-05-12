class FindCriteria

	def initialize(ns = "typ1", params = {})
		@ns = ns
		@params = params
	end

	def to_s
    xml_builder = Builder::XmlMarkup.new
    xml_builder.types :findCriteria do |xml|
      xml.tag!("#{@ns}:fetchStart", 0)
      xml.tag!("#{@ns}:fetchSize", 10)
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