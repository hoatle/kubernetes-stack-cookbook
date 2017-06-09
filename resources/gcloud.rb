resource_name :gcloud

# property :version, String, default: nil

default_action :install

load_current_value do
end

action :install do
  # TODO(hoatle): support more platform, support specified version installation
  if platform?('ubuntu')
    execute 'import google-cloud-sdk public key' do
      command 'curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -'
    end

    apt_repository 'google-cloud-sdk' do
      uri          'http://packages.cloud.google.com/apt'
      distribution "cloud-sdk-#{node['lsb']['codename']}"
      components   ['main']
      # key 'A7317B0F'
      # keyserver 'packages.cloud.google.com/apt/doc/apt-key.gpg'
    end
    package 'google-cloud-sdk'
  end
end

action :remove do
  package 'google-cloud-sdk' do
    action :remove
  end
end
