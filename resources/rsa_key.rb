actions :create
default_action :create

attribute :name, kind_of: String, name_attribute: true
attribute :bits, equal_to: [1024, 2048, 4096, 8192], default: 2048
attribute :key_pass, kind_of: String, default: nil
attribute :owner, kind_of: String, default: 'root'
attribute :group, kind_of: String, default: 'root'
attribute :mode, kind_of: [Integer, String]
