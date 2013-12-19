require 'spec_helper'
require 'db_init'

class TestMigration < ActiveRecord::Migration
  def self.up
    create_table :books, :force => true do |t|
      t.column  :title, :string
      t.column  :price, :integer
      t.column  :kind,  :string
      t.column  :url,   :string
    end
  end

  def self.down
    drop_table  :books
  end
end

class Book < ActiveRecord::Base
  excel_import  :common,  :fields => [:title, :price, :kind]

  excel_import  :progream,:fields => [:title, :price, :url],
                          :default => {
                            :kind => '编辑'
                          }
end

describe "Excel 导入" do

  before{
    TestMigration.up
  }

  after{
    TestMigration.down
  }

  


end

