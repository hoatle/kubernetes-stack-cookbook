# # encoding: utf-8

# Inspec test for recipe kubernetes-stack::helm

# The Inspec reference, with examples and extensive document

describe command('uname').exist? do
  it { should eq true }
end

describe command('uname -m') do
  its(:exit_status) { should eq 0 }
end

describe command("curl -s https://api.github.com/repos/kubernetes/helm/releases/latest | grep 'tag_name' | cut -d\\\" -f4") do
  its(:exit_status) { should eq 0 }
  its('stdout') { should match /^\s*v[0-9]+.[0-9]+.[0-9]+?$/ }
end

describe file('/usr/local/bin/helm') do
  it { should exist }
  its('size') { should be > 0 }
end
