resource_name :gcloud

property :version, String, default: ''
property :binary_path, String, default: '/usr/local/bin/gcloud'

default_action :install

load_current_value do
end

action :install do
  # Get infomation of operation system
  platform = platform()
  arch = arch()
  arch_core = arch_core(arch)

  # version will be installed
  latest_version = latest_version()
  version = latest_version
  version = new_resource.version unless new_resource.version.empty?
  existing_version = existing_version()

  # Compare existing_version vs version
  if existing_version != version
    # Deleting previous version if mismatched
    delete_gcloud(binary_path)

    # Check version if version avaiable in apt-get package (ubuntu)
    # Avaiable version get from https://packages.cloud.google.com/apt/dists/cloud-sdk-$('lsb_release -c -s')/main/binary-#{arch}/Packages
    # Installing gcloud autocomplete via apt-get will be faster
    # issue (https://github.com/teracyhq-incubator/kubernetes-stack-cookbook/issues/19)
    if platform?('ubuntu')
      version_avaiable = version_avaiable_in_apt_package?(arch_core, version) unless arch_core.to_s.strip.empty?
    end

    # Gcloud version will be installed via apt-get
    if version_avaiable
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

      if version == latest_version
        package 'google-cloud-sdk'
      else
        package 'google-cloud-sdk' do
          version "#{version}-0"
        end
      end

      # Link to binary_path
      link_to_path_env(binary_path)
      # Disable update notification when run command 'gcloud version'
      disable_update_check
    # Gcloud version will be installed via file downloaded
    else
      # Check requirement to install
      install_requirement

      download_url = "https://storage.googleapis.com/cloud-sdk-release/google-cloud-sdk-#{version}-#{platform}-#{arch}.tar.gz"

      execute "curl #{download_url} | tar xvz" do
        cwd '/usr/lib'
        action :run
        not_if 'which gcloud'
      end

      execute './google-cloud-sdk/install.sh --quiet' do
        cwd '/usr/lib'
        action :run
        only_if 'test -d /usr/lib/google-cloud-sdk'
      end

      # Link to binary_path
      link_to_path_env(binary_path)
      # Disable update notification when run command 'gcloud version'
      disable_update_check
      # Install autocomplete
      install_autocomplete
    end
  end
end

action :remove do
  delete_gcloud(binary_path)
end

action_class do
  def platform
    platform_cmd = Mixlib::ShellOut.new('uname')
    platform_cmd.run_command
    platform_cmd.error!
    platform = platform_cmd.stdout.strip.downcase
    platform
  end

  def arch
    arch_cmd = Mixlib::ShellOut.new('uname -m')
    arch_cmd.run_command
    arch_cmd.error!
    arch = arch_cmd.stdout.strip
    arch
  end

  def arch_core(arch)
    case arch
    when 'x86', 'i686', 'i386'
      '386'
    when 'x86_64', 'aarch64'
      'amd64'
    when 'armv5*'
      'armv5'
    when 'armv6*'
      'armv6'
    when 'armv7*'
      'armv7'
    else
      ''
    end
  end

  def latest_version
    latest_version_url = "curl -s https://cloud.google.com/sdk/docs/release-notes | grep 'h2' | head -1 | cut -d '>' -f2 | sed 's/[[:space:]].*//'"
    latest_version_cmd = Mixlib::ShellOut.new(latest_version_url)
    latest_version_cmd.run_command

    latest_version = ''
    latest_version = latest_version_cmd.stdout.strip if latest_version_cmd.stderr.empty? && !latest_version_cmd.stdout.empty?
    latest_version
  end

  def existing_version
    existing_version_cmd = Mixlib::ShellOut.new("gcloud version | head -1 | grep -o -E '[0-9].*'")
    existing_version_cmd.run_command

    existing_version = ''
    existing_version = existing_version_cmd.stdout.strip if existing_version_cmd.stderr.empty? && !existing_version_cmd.stdout.empty?
    existing_version
  end

  def delete_gcloud(binary_path)
    if platform?('ubuntu')
      execute 'to complete remove gcloud' do
        command 'apt-get purge --auto-remove -y google-cloud-sdk'
        action :run
      end
    end

    file 'cleanup_binany_path' do
      path binary_path
      action :delete
      only_if 'which gcloud'
    end

    directory 'cleanup_root_config_path' do
      path '/root/.config/gcloud'
      recursive true
      action :delete
      only_if 'test -d /root/.config/gcloud'
    end

    directory 'cleanup_user_config_path' do
      path '/home/vagrant/.config/gcloud'
      recursive true
      action :delete
      only_if 'test -d /home/vagrant/.config/gcloud'
    end

    directory 'cleanup_install_root_dir' do
      path '/usr/lib/google-cloud-sdk'
      recursive true
      action :delete
      only_if 'test -d /usr/lib/google-cloud-sdk'
    end

    file 'cleanup_completion_path' do
      path '/etc/bash_completion.d/gcloud'
      action :delete
      only_if 'test -f /etc/bash_completion.d/gcloud'
    end

    file 'cleanup_gcloud_package_source' do
      path '/etc/apt/sources.list.d/google-cloud-sdk.list'
      action :delete
      only_if 'test -f /etc/apt/sources.list.d/google-cloud-sdk.list'
    end
  end

  def version_avaiable_in_apt_package?(arch_core, version)
    version_avaiable_cmd = Mixlib::ShellOut.new("curl -s https://packages.cloud.google.com/apt/dists/cloud-sdk-$(lsb_release -c -s)/main/binary-#{arch_core}/Packages | grep 'google-cloud-sdk_#{version}'")
    version_avaiable_cmd.run_command

    version_avaiable = false
    if version_avaiable_cmd.stderr.empty? && !version_avaiable_cmd.stdout.empty?
      version_avaiable = true
    end
    version_avaiable
  end

  def link_to_path_env(binary_path)
    link binary_path do
      to '/usr/lib/google-cloud-sdk/bin/gcloud'
      mode '0755'
      only_if 'test -f /usr/lib/google-cloud-sdk/bin/gcloud'
    end

    # Add gsutil to ENV_PATH
    link '/usr/local/bin/gsutil' do
      to '/usr/lib/google-cloud-sdk/bin/gsutil'
      mode '0755'
      only_if 'test -f /usr/lib/google-cloud-sdk/bin/gsutil'
    end

    # Add bq command to ENV_PATH
    link '/usr/local/bin/bq' do
      to '/usr/lib/google-cloud-sdk/bin/bq'
      mode '0755'
      only_if 'test -f /usr/lib/google-cloud-sdk/bin/bq'
    end
  end

  def disable_update_check
    # Disable update notification when run command 'gcloud version'
    execute 'disable update check' do
      command 'gcloud config set --installation component_manager/disable_update_check true'
      only_if 'which gcloud'
    end

    # Update file config.json
    execute 'update gcloud file config' do
      command "sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' /usr/lib/google-cloud-sdk/lib/googlecloudsdk/core/config.json"
      only_if 'test -f /usr/lib/google-cloud-sdk/lib/googlecloudsdk/core/config.json'
    end
  end

  def package_name
    case node['platform']
    when 'debian', 'ubuntu'
      'apt-get'
    when 'redhat', 'centos', 'fedora'
      'yum'
    end
  end

  def install_requirement
    package_name = package_name()
    install_python(package_name)
    install_bash_completion_ubuntu if node['platform'] == 'ubuntu'
    install_bash_completion_centos if node['platform'] == 'centos'
  end

  def install_python(package_name)
    execute 'check exist and install python' do
      command "#{package_name} install -y python"
      not_if 'which python'
    end
  end

  def install_bash_completion_ubuntu
    bash 'check exist and install bash-completion' do
      code <<-EOH
        apt-get install bash-completion
        . /etc/bash_completion
        EOH
      not_if { ::File.exist?('/etc/bash_completion') && ::File.exist?('/usr/share/bash-completion/bash_completion') }
    end
  end

  def install_bash_completion_centos
    execute 'check exist and install bash-completion' do
      command 'yum install -y bash-completion'
      not_if { ::File.exist?('/etc/profile.d/bash_completion.sh') && ::File.exist?('/usr/share/bash-completion/bash_completion') }
    end

    bash 'add it to the bash profile' do
      code <<-EOH
        . /etc/profile.d/bash_completion.sh
        EOH
      only_if { node['platform_version'].to_f > 7.0 }
    end
  end

  def install_autocomplete
    remote_file 'install autocomplete' do
      path '/etc/bash_completion.d/gcloud'
      source 'file:///usr/lib/google-cloud-sdk/completion.bash.inc'
      owner 'root'
      group 'root'
      mode '0755'
      only_if 'test -f /usr/lib/google-cloud-sdk/completion.bash.inc'
    end

    link '/etc/bash_completion.d/gcloud' do
      to '/usr/lib/google-cloud-sdk/completion.bash.inc'
      mode '0755'
      only_if 'test -f /etc/bash_completion.d/gcloud'
    end
  end
end
