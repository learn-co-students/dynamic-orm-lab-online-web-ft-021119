require 'sqlite3''~>1.3.6'
require 'pry'
# A sample Gemfile
# source "https://rubygems.org"
#
# gem 'pry'
# gem 'sqlite3', '~>1.3.6'

DB = {:conn => SQLite3::Database.new("db/students.db")}
DB[:conn].execute("DROP TABLE IF EXISTS students")

sql = <<-SQL
  CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY,
  name TEXT,
  grade INTEGER
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true
