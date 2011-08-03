def initialize(*args)
  super
  @action = :create
end

actions :create

attribute :server_name, :name_attribute => true, :kind_of => String
attribute :port, :kind_of => Integer
attribute :ssl, :kind_of => [ TrueClass, FalseClass ]
attribute :internal_locations, :kind_of => Array
