module Queryable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    #put class methods here
  end

  #put instance methods here
  def find_criteria(ns = "types")
    {
      "#{ns}:findCriteria" => [fetching]
    }
  end

  def fetching(ns = "typ1", fetchStart = 0, fetchSize = @max_fetch_size)
    {
      "#{ns}:fetchStart" => fetchStart,
      "#{ns}:fetchSize"  => fetchSize
    }
  end
end
