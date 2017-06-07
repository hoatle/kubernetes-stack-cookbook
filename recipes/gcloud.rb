#
# Cookbook:: kubernetes
# Recipe:: gcloud
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

# install and configure google cloud sdk

# https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu

# TODO(hoatle): not sure why key and keyserver from apt_repository did not work
# this is the workaround for that

k8s_conf = node['kubernetes']
gcloud_conf = k8s_conf['gcloud']

if gcloud_conf['enabled']

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
