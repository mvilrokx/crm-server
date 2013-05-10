module Queryable

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    attr_accessor :max_fetch_size

    def find_criteria
      {
        "types:findCriteria" => [self.fetching]
      }
    end

    def fetching(fetchStart = 0, fetchSize = max_fetch_size)
      {
        "typ1:fetchStart" => fetchStart,
        "typ1:fetchSize"  => fetchSize
      }
    end
  end
  #put instance methods here
end
