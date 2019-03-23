require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'interactive_record.rb'

class Student < InteractiveRecord

  #method to declare abstractive attr_accessor
  self.column_names.each do |name|
    attr_accessor name.to_sym
  end

end
