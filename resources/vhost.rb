def initialize(*args)
  super
  @action = :create
end

actions :create

attribute :server_name, :name_attribute => true, :kind_of => String
attribute :listen_string, :kind_of => String
