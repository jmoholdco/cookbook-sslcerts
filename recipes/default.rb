#
# Cookbook Name:: ssl_certs
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.
#

sslcerts_certificate node['fqdn'] do
  action :create
  ssl_dir node['sslcerts']['dir']
  request_subject node['sslcerts']['request']['subject']
end
