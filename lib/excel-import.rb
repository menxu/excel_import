# -*- encoding : utf-8 -*-
require 'roo'
require 'axlsx'

module ExcelImport
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def excel_import(role, options = {})
        fields = options[:fields]
        default = options[:default] || {}

        class_eval %(
          def self.parse_excel_#{role}(excel_file)
            _excel_import(#{fields}, #{default}, excel_file)
          end

          def self.import_excel_#{role}(excel_file)
            models = _excel_import(#{fields}, #{default}, excel_file)
            models.each do |model|
              model.save
            end
            models
          end

          def self.get_excel_#{role}
            _excel_import_generate_sample(#{fields}, #{default})
          end
        )
      end

      private
        def _excel_import(fields, default, excel_file)
          spreadsheet = ExcelImport::ImportFile.open_spreadsheet(excel_file)

          models = []
          (2..spreadsheet.last_row).each do |i|
            row = spreadsheet.row(i)

            params = {}
            fields.each_index do |index|
              data = row[index].is_a?(Float) ? row[index].to_i.to_s : row[index].to_s
              params[fields[index]] = data
            end
            params.merge! default

            models << self.new(params)
          end
          models
        end

        def _excel_import_generate_sample(fields, default)
          file = Tempfile.open [self.to_s, '.xlsx']

          output = Axlsx::Package.new
          output.workbook.add_worksheet(:name => 'sheet') do |sheet|
            field_strs = fields.map do |field|
              I18n.t("activerecord.attributes.#{self.name.downcase}.#{field}")
            end

            sheet.add_row field_strs
          end
          output.use_shared_strings = true
          output.serialize(file)
          file
        end
    end
  end

  module ImportFile
    class FormatError < Exception; end

    def self.open_spreadsheet(file)
      extname = case file
      when ActionDispatch::Http::UploadedFile
        File.extname file.original_filename
      else
        File.extname file
      end

      case extname
        when '.sxc'
          Roo::Openoffice.new(file.path, nil, :ignore)
        when '.xls'
          Roo::Excel.new(file.path, nil, :ignore)
        when '.xlsx'
          Roo::Excelx.new(file.path, nil, :ignore)
        else
          raise FormatError.new "Unsupported file format #{extname}"
      end

    end
  end

end

ActiveRecord::Base.send :include, ExcelImport::Base
