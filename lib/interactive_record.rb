require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def table_name_for_insert
    self.class.table_name
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    column_names = []

    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)

    table_info.each do |column|
      column_names<< column["name"]
    end

    column_names.compact # => ["id", "name", "grade"]
  end

  def initialize(options={})
    options.each do |k,v|
      self.send("#{k}=", v)
    end
  end




end
