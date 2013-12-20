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
  excel_import :common, :fields => [:title, :price, :url],
                                :default => {
                                  :kind => '编程'
                                }

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


end

