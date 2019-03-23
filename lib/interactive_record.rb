require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    DB[:conn].results_as_hash = true
    sql = "PRAGMA table_info('#{table_name}')"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |info|
      column_names << info["name"]
    end
    column_names.compact
  end

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

  def initialize(options={})
    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.to_s.downcase.pluralize
  end

  def col_names_for_insert
    sql = <<-SQL
      PRAGMA table_info('#{table_name_for_insert}')
      SQL
    table_info = DB[:conn].execute(sql)
    # binding.pry
    col_names = []
    table_info.select {|column| col_names << column['name']}
    # binding.pry
    col_names.delete('id')
    col_names.compact.join(', ')
  end

  def new_col_names
    self.col_names_for_insert.split(", ").map{|i| "'"+i+"'"}.join
  end

  def values_for_insert
    # new = self.col_names_for_insert.split(", ").map{|i| "'"+i+"'"}.join(", ")
    sql = <<-SQL
      SELECT '#{new_col_names}'
      FROM '#{table_name_for_insert}'
    SQL
    binding.pry

    new = DB[:conn].execute(sql)

    # new = self.col_names_for_insert.split(", ").map{|i| "'"+i+"'"}.join(", ")
    # col_names_for_insert.split(", ").map{|i| "'"+i+"'"}.join(", ")
  end








end
