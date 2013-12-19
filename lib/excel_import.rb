module ExcelImport
  module Base
    extend ActiveSupport::Concern

    module ClassModule
      def demo_method
        puts "demo demo_method"
      end
    end
  end
end

ActiveRecord::Base.send :include, ExcelImport::Base
