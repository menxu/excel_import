# -*- encoding : utf-8 -*-
require 'spec_helper'
require 'db_init'

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :books, :force => true do |t|
      t.column :title, :string
      t.column :price, :integer
      t.column :kind,  :string
      t.column :url,   :string
    end

  end

  def self.down
    drop_table :books
  end
end

class Book < ActiveRecord::Base
  excel_import :common, :fields => [:title, :price, :kind]

  excel_import :program, :fields => [:title, :price, :url],
                                :default => {
                                  :kind => '编程'
                                }
end


describe 'Excel导入' do

  before {
    TestMigration.up
  }

  after { 
    TestMigration.down
  }

  describe '方法定义' do
    it {
      Book.methods.include?(:parse_excel_program).should == true
    }
    it {
      Book.methods.include?(:import_excel_program).should == true
    }
    it {
      Book.methods.include?(:get_excel_program).should == true
    }

    it {
      Book.methods.include?(:parse_excel_common).should == true
    }
    it {
      Book.methods.include?(:import_excel_common).should == true
    }
    it {
      Book.methods.include?(:get_excel_common).should == true
    }

  end

  describe '.parse_excel_**' do
    context 'common_books' do
      before {
        @common_books = Book.parse_excel_common File.new('spec/data/common_books.xls')
      }

      it {
        @common_books.count.should == 4
      }

      it{
        @common_books.each { |book|
          book.should be_new_record
        }
      }

      it {
        Book.count.should == 0
      }

      it '查看标题' do
        @common_books.map { |book|
          book.title
        }.should == ['ruby 元编程','智慧背囊','新疆之疆','大地之母']
      end

      it '查看价格' do
        @common_books.map { |book|
          book.price
        }.should == [65,136,58,68]
      end

      it '查看分类' do
        @common_books.map { |book|
          book.kind
        }.should == ['编程','读物','地理','文学']
      end

      it '查看不存在' do
        @common_books.map { |book|
          book.url
        }.should == [nil,nil,nil,nil]
      end
    end

    context 'program_books' do
      before {
        @program_books = Book.parse_excel_program File.new('spec/data/program_books.xls')
      }

      it {
        @program_books.count.should == 5
      }

      it {
        @program_books.each { |book|
          book.should be_new_record
        }
      }

      it {
        Book.count.should == 0
      }

      it '检查标题' do
        @program_books.map { |book|
          book.title
        }.should == ['松本行弘的程序世界', 'HTML5移动开发即学即用', '版本控制之道——使用Git', 'Ruby Cookbook', 'Java 面向对象']
      end

      it '检查分类' do
        @program_books.map { |book|
          book.kind
        }.should == ['编程', '编程', '编程', '编程', '编程']
      end

      it '检查价格' do
        @program_books.map { |book|
          book.price
        }.should == [75, 59, 39, 108, 98]
      end

      it '检查URL' do
        @program_books.map { |book|
          book.url
        }.should == ['http://sample/ruby', 'http://sample/html5', 'http://sample/git', 'http://sample/rubycook','http://sample/java']
      end
    end
  end

  describe '.import_excel_**' do
    context 'common_books' do
      before {
        Book.import_excel_common File.new('spec/data/common_books.xls')
      }

      it {
        Book.count.should == 4
      }

      it '检查标题' do
        Book.all.map { |book|
          book.title
        }.should == ['ruby 元编程','智慧背囊','新疆之疆','大地之母']
      end

      it '检查价格' do
        Book.all.map { |book|
          book.price
        }.should == [65,136,58,68]
      end

      it '检查分类' do
        Book.all.map { |book|
          book.kind
        }.should == ['编程','读物','地理','文学']
      end

      it '检查分类' do
        Book.all.map { |book|
          book.url
        }.should == [nil, nil, nil, nil]
      end
    end

    context 'program_books' do
      before {
        Book.import_excel_program File.new('spec/data/program_books.xls')
      }

      it {
        Book.count.should == 5
      }

      it '检查标题' do
        Book.all.map { |book|
          book.title
        }.should == ['松本行弘的程序世界', 'HTML5移动开发即学即用', '版本控制之道——使用Git', 'Ruby Cookbook', 'Java 面向对象']
      end

      it '检查分类' do
        Book.all.map { |book|
          book.kind
        }.should == ['编程', '编程', '编程', '编程', '编程']
      end

      it '检查价格' do
        Book.all.map { |book|
          book.price
        }.should == [75, 59, 39, 108,98]
      end

      it '检查URL' do
        Book.all.map { |book|
          book.url
        }.should == ['http://sample/ruby', 'http://sample/html5', 'http://sample/git', 'http://sample/rubycook', 'http://sample/java']
      end
    end
  end

  describe '.get_excel_xxx' do
    before {
      sample_file = Book.get_excel_common
      @spreadsheet = ExcelImport::ImportFile.open_spreadsheet sample_file
    }

    it {
      @spreadsheet.last_row.should == 1 # 共一行
    }

    it {
      @spreadsheet.last_column.should == 3 # 共三列
    }

    it {
      @spreadsheet.cell(1, 1).should == I18n.t('activerecord.attributes.book.title')
    }

    it {
      @spreadsheet.cell(1, 2).should == I18n.t('activerecord.attributes.book.price')
    }

    it {
      @spreadsheet.cell(1, 3).should == I18n.t('activerecord.attributes.book.kind')
    }
  end

  describe ActionDispatch::Http::UploadedFile do
    before {
      upload_file = ActionDispatch::Http::UploadedFile.new({
        :filename => 'common_books.xls',
        :tempfile => File.new('spec/data/common_books.xls')
      })

      Book.import_excel_common upload_file
    }

    it {
      Book.count.should == 4
    }
  end
end

