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
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = <<-SQL
    INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
    VALUES (#{values_for_insert})
    SQL

    DB[:conn].execute(sql)

    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(attribute)
    binding.pry
    column = attribute.keys
    data = nil
    if attribute.values == Integer
      data = attribute.values
    else
      data = "'#{attribute.values}'"
    end
    sql = <<-SQL
    SELECT * FROM #{self.table_name} WHERE #{column[0]} = #{data}
    SQL
    DB[:conn].execute(sql)
  end


end
