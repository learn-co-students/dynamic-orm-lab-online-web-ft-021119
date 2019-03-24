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

  def col_names_for_insert
    self.class.column_names.delete_if{|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{self.send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end


  def initialize(options={})
    options.each do |k,v|
      self.send("#{k}=", v)
    end
  end

  # def save
  #   question_marks_for_insert = values_for_insert.split.map {|val| val = "?"}.join(", ")
  #   sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{question_marks_for_insert})"
  #   sql = sql.split.compact.join(" ")
  #
  #   DB[:conn].execute(sql, "#{values_for_insert.split[1..-1].join}")
  #   @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  # end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{table_name} WHERE name = ?"
    result =  DB[:conn].execute(sql, name)
    #binding.pry
  end

  def self.find_by(attribute)
  column_name = attribute.keys[0].to_s
  value_name = attribute.values[0]

  sql = <<-SQL
    SELECT * FROM #{table_name}
    WHERE #{column_name} = ?
    SQL

  DB[:conn].execute(sql, value_name);
end

end
