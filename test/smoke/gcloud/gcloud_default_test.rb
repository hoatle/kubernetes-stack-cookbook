# # encoding: utf-8

# Inspec test for recipe kubernetes-stack::gcloud

# The Inspec reference, with examples and extensive document

describe command('uname').exist? do
  it { should eq true }
end

describe command('uname -m') do
  its(:exit_status) { should eq 0 }
end

describe command('which python') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match('/usr/bin/python') }
end

describe command("curl -s https://cloud.google.com/sdk/docs/release-notes | grep 'h2' | head -1 | cut -d '>' -f2 | sed 's/[[:space:]].*//'") do
  its(:exit_status) { should eq 0 }
  its('stdout') { should match /^\s*[0-9]+.[0-9]+.[0-9]+?$/ }
end

describe file('/usr/lib/google-cloud-sdk/bin/gcloud') do
  it { should exist }
  its('size') { should be > 0 }
end

describe file('/usr/local/bin/gcloud') do
  it { should exist }
  it { should be_symlink }
  it { should be_linked_to '/usr/lib/google-cloud-sdk/bin/gcloud' }
  its('size') { should be > 0 }
end
