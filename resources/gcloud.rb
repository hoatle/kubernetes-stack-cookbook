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
  if version.empty?
    latest_version_url = "curl -s https://cloud.google.com/sdk/docs/release-notes | grep 'h2' | head -1 | cut -d '>' -f2 | sed 's/[[:space:]].*//'"
    latest_version_cmd = Mixlib::ShellOut.new(latest_version_url)
    latest_version_cmd.run_command
    latest_version_cmd.error!
    version = latest_version_cmd.stdout.strip
  end

  # Command to check if we should be installing gcloud or not.
  existing_version_cmd = Mixlib::ShellOut.new("gcloud version | head -1 | grep -o -E '[0-9].*'")
  existing_version_cmd.run_command

  if existing_version_cmd.stderr.empty? && !existing_version_cmd.stdout.empty?
    existing_version = existing_version_cmd.stdout.strip
  end

  if existing_version != version
    bash 'clean up the mismatched gcloud version' do
      code <<-EOF
        gcloud_binary=$(which gcloud);
        rm -rf $gcloud_binary;
        rm -rf /$(whoami)/.config/gcloud;
        rm -rf /usr/lib/google-cloud-sdk/;
        EOF
      only_if 'which gcloud'
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
      cwd '/usr/lib'
      code <<-EOH
          curl #{download_url} | tar xvz
          cd google-cloud-sdk
          ./install.sh --usage-reporting=false --path-update=true --bash-completion=true --rc-path=~/.bashrc || true
          /usr/lib/google-cloud-sdk/bin/gcloud config set --installation component_manager/disable_update_check true || true
          sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /usr/lib/google-cloud-sdk/lib/googlecloudsdk/core/config.json || true
          echo "source '/usr/lib/google-cloud-sdk/completion.bash.inc'" >> ~/.bashrc || true
          echo "source '/usr/lib/google-cloud-sdk/completion.bash.inc'" >> /etc/bash.bashrc || true
          source ~/.bashrc || true
          EOH
      user 'root'
      group 'root'
      not_if { ::File.exist?(binary_path) }
    end

    link binary_path do
      to '/usr/lib/google-cloud-sdk/bin/gcloud'
      only_if 'test -f /usr/lib/google-cloud-sdk/bin/gcloud'
    end
  end
end

action :remove do
  bash 'clean up gcloud' do
    code <<-EOH
      rm -rf #{binary_path}
      rm -rf /$(whoami)/.config/gcloud
      rm -rf /usr/lib/google-cloud-sdk/
      EOH
    only_if 'which gcloud'
  end
end
