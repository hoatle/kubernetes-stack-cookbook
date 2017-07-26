resource_name :gcloud

property :version, String, default: ''
property :binary_path, String, default: '/usr/local/bin/gcloud'

default_action :install

load_current_value do
end

action :install do
  platform_cmd = Mixlib::ShellOut.new('uname')
  platform_cmd.run_command
  platform_cmd.error!
  platform = platform_cmd.stdout.strip.downcase

  arch_cmd = Mixlib::ShellOut.new('uname -m')
  arch_cmd.run_command
  arch_cmd.error!
  arch = arch_cmd.stdout.strip

  version = new_resource.version
  bash 'clean up the mismatched gcloud version' do
    code <<-EOF
      gcloud_binary=$(which gcloud);
      existing_version=$(gcloud version | head -1 | grep -o -E '[0-9].*');
      if [ "$existing_version" != "#{version}" ]; then
        rm -rf $gcloud_binary || true;
        rm -rf /$(whoami)/.config/gcloud || true;
        rm -rf /usr/lib/google-cloud-sdk/ || true;
      fi
    EOF
    only_if 'which gcloud'
  end

  if version.empty?
    latest_version_url = "curl -s https://cloud.google.com/sdk/docs/release-notes | grep 'h2' | head -1 | cut -d '>' -f2 | sed 's/[[:space:]].*//'"
    latest_version_cmd = Mixlib::ShellOut.new(latest_version_url)
    latest_version_cmd.run_command
    latest_version_cmd.error!
    version = latest_version_cmd.stdout.strip
  end

  download_url = "https://storage.googleapis.com/cloud-sdk-release/google-cloud-sdk-#{version}-#{platform}-#{arch}.tar.gz"
  if platform?('ubuntu')
    execute 'check exist and install python' do
      command 'apt-get install -y python'
      not_if 'which python'
    end
  end

  if platform?('centos')
    execute 'check exist and install python' do
      command 'yum install -y python'
      not_if 'which python'
    end
  end

  bash 'install gcloud' do
    user 'root'
    cwd '/usr/lib'
    code <<-EOH
        curl #{download_url} | tar xvz
        cd google-cloud-sdk
        ./install.sh --usage-reporting=true --path-update=true --command-completion=true --bash-completion=true --rc-path=$(whoami)/.bashrc
        EOH
    not_if { ::File.exist?(binary_path) }
  end

  link binary_path do
    to '/usr/lib/google-cloud-sdk/bin/gcloud'
    only_if 'test -f /usr/lib/google-cloud-sdk/bin/gcloud'
  end
  # end
end

action :remove do
  package 'google-cloud-sdk' do
    action :remove
  end
end
