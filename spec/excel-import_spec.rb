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

  excel_import :progream, :fields => [:title, :price, :url],
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
      Book.methods.include?(:parse_excel_progream).should == true
    }
    it {
      Book.methods.include?(:import_excel_progream).should == true
    }
    it {
      Book.methods.include?(:get_excel_progream).should == true
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
  end

end

