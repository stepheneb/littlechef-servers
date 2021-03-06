# make sure our package listing is up-to-date
# this is done when chef-ruby runs
# execute "apt-get update" do
#   action :run
#   user "root"
# end

package "unzip"
include_recipe "cc-rails"

cc_rails = node[:cc_rails]
approot = cc_rails[:approot]
appshared = cc_rails[:appshared]
site_id = cc_rails[:site_id]
site_item = data_bag_item('sites', site_id)
lara = node[:lara]

# override the app_environment_variables.rb settings
template "#{appshared}/config/app_environment_variables.rb" do
  @sso_server_url    = lara[:sso_server_url]
  @sso_client_id     = lara[:sso_client_id]
  @sso_client_secret = data_bag_item('credentials', 'sso')[@sso_client_id]
  @rails_cookie_token = data_bag_item('credentials', 'rails_cookie_token')['lara']
  source "app_environment_variables.rb.erb"
  owner "deploy"
  variables(
    :sso_server_url    => @sso_server_url,
    :sso_client_id     => @sso_client_id,
    :sso_client_secret => @sso_client_secret,
    :rails_cookie_token => @rails_cookie_token
  )
  notifies :run, "execute[restart webapp]"
end
