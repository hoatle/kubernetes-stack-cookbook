resource_name :kubectl

property :version, String, default: ''
property :binary_path, String, default: '/usr/local/bin/kubectl'

default_action :install

load_current_value do
end

action :install do
  if version.empty?
    latest_version_url = 'curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt'
    version_cmd = Mixlib::ShellOut.new(latest_version_url)
    version_cmd.run_command
    version_cmd.error!
    version = version_cmd.stdout.strip
  end

  bash 'clean up the mismatched kubectl version' do
    code <<-EOF
      kubectl_binary=$(which kubectl);
      existing_version=$(kubectl version --short --client | cut -d ':' -f2);
      if [ "$existing_version" != "#{version}" ]; then
        rm -rf $kubectl_binary || true;
      fi
    EOF
    only_if 'which kubectl'
  end

  download_url = "https://storage.googleapis.com/kubernetes-release/release/#{version}/bin/linux/amd64/kubectl"

  remote_file binary_path do
    source download_url
    mode '0755'
    not_if { ::File.exist?(binary_path) }
  end
end

action :remove do
  execute 'remove kubectl' do
    command "rm -rf #{binary_path}"
    only_if 'which kubectl'
  end
end
