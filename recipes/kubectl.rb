#
# Cookbook:: kubernetes-stack
# Recipe:: kubectl
#
# The MIT License (MIT)
#
# Copyright:: 2017, Teracy Corporation
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

k8s_conf = node['kubernetes-stack']
kubectl_conf = k8s_conf['kubectl']

if kubectl_conf['enabled'] == true

  if kubectl_conf['version'] && !kubectl_conf['version'].empty?
    version = kubectl_conf['version']
  else
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
    user 'root'
  end

  download_url = "https://storage.googleapis.com/kubernetes-release/release/#{version}/bin/linux/amd64/kubectl"
  kubectl_binary = '/usr/local/bin/kubectl'

  remote_file kubectl_binary.to_s do
    source download_url
    mode '0755'
    not_if { File.exist?(kubectl_binary) }
  end
end
