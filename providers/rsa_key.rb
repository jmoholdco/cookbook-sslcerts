include SSLCertsCookbook::Helpers

use_inline_resources

def whyrun_supported?
  true
end

action :create do
  converge_by("Create an RSA key #{@new_resource}") do
    unless key_file_valid?(new_resource.name, new_resource.key_pass)
      log "Generating #{new_resource.bits} bit "\
          "RSA key file at #{new_resource.name}, this may take a while..."

      if new_resource.key_pass
        unencrypted_rsa = gen_rsa(new_resource.bits)
        rsa_content = encrypt_rsa_key(unencrypted_rsa, new_resource.key_pass)
      else
        rsa_content = gen_rsa(new_resource.bits).to_pem
      end

      file new_resource.name do
        action :create
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
        sensitive true
        content rsa_content
      end
    end
  end
end
