require 'chef/mixin/shell_out'
require 'chef/dsl/recipe'

class Chef
  class Provider
    class CaCertificate < Chef::Provider
      include Chef::DSL::Recipe
      include Chef::Mixin::ShellOut
      include SSLCertsCookbook::Helpers
      include Chef::DSL::Recipe

      def load_current_resource
        @current_resource ||= Chef::Resource::CaCertificate.new(
          @new_resource.name
        )
        @on_disk = true if ca_exists?
        @in_vault = true if ca_in_vault?
        @current_resource
      end

      def action_create
        unless @on_disk
          generate_private_key
          cert = if new_resource.authority_type == 'root'
                   generate_self_signed
                 else
                   generate_ca_csr
                 end
        end
      end

      protected

      def generate_private_key
        pkey = gen_rsa(new_resource.bits, new_resource.key_password)
        file new_resource.private_key_path do
          owner 'root'
          group 'root'
          mode '0400'
          sensitive true
          content pkey.to_pem
        end
      end

      def generate_self_signed
      end
    end
  end
end
