module JsonApiClientMock
  module ResourceExtensions
    extend ActiveSupport::Concern

    included do
      class_attribute :test_mocks
      self.test_mocks = []
      class << self
        alias_method_chain :find, :mocking
      end
    end

    module ClassMethods
      def set_test_results(results, conditions = nil)
        self.test_mocks.unshift({results: results, conditions: conditions})
        true
      end

      def clear_test_results
        self.test_mocks = []
      end

      def find_with_mocking(conditions)
        results = self.test_mocks.detect{|mock| mock[:conditions] == conditions} || 
          self.test_mocks.detect{|mock| mock[:conditions].nil?}

        if results
          Array(results[:results]).map{|data| new(data)}
        else
          raise(MissingMock, "no test results set for #{self.name} with conditions: #{conditions.inspect}")
        end
      end
    end
  end
end