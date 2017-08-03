# # encoding: utf-8

# Inspec test for recipe kubernetes-stack::kubectl

# The Inspec reference, with examples and extensive document

describe command('rm -rf /usr/local/bin/kubectl') do
  its(:stderr) { should eq '' }
end

describe command('which kubectl') do
  its(:exit_status) { should eq 1 }
end
