# # encoding: utf-8

# Inspec test for recipe kubernetes-stack::kubectl

# The Inspec reference, with examples and extensive document

describe command('uname').exist? do
  it { should eq true }
end

describe command('uname -m') do
  its(:exit_status) { should eq 0 }
end

describe command('curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt') do
  its(:exit_status) { should eq 0 }
  its('stdout') { should match /^\s*v[0-9]+.[0-9]+.[0-9]+?$/ }
end

describe file('/usr/local/bin/kubectl') do
  it { should exist }
  its('size') { should be > 0 }
  its('mode') { should cmp '0755' }
end
