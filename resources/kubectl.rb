resource_name :kubectl

property :version, String, default: ''
property :binary_path, String, default: '/usr/local/bin/kubectl'

default_action :install

load_current_value do
end

action :install do
  platform_cmd = Mixlib::ShellOut.new('uname')
  platform_cmd.run_command
  platform_cmd.error!
  platform = platform_cmd.stdout.strip.downcase

  version = new_resource.version

  arch_cmd = Mixlib::ShellOut.new('uname -m')
  arch_cmd.run_command
  arch_cmd.error!
  arch = arch_cmd.stdout.strip

  case arch
  when 'x86', 'i686', 'i386'
    arch = '386'
  when 'x86_64', 'aarch64'
    arch = 'amd64'
  when 'armv5*'
    arch = 'armv5'
  when 'armv6*'
    arch = 'armv6'
  when 'armv7*'
    arch = 'armv7'
  else
    arch = 'default'
  end

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

  download_url = "https://storage.googleapis.com/kubernetes-release/release/#{version}/bin/#{platform}/#{arch}/kubectl"

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
