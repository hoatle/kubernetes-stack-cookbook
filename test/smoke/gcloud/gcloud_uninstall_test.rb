# # encoding: utf-8

# Inspec test for recipe kubernetes-stack::gcloud

# The Inspec reference, with examples and extensive document

describe command('rm -rf /usr/local/bin/gcloud') do
  its(:stderr) { should eq '' }
end

describe command('rm -rf /$(whoami)/.config/gcloud') do
  its(:stderr) { should eq '' }
end

describe command('rm -rf /usr/lib/google-cloud-sdk/') do
  its(:stderr) { should eq '' }
end

describe command('which helm') do
  its(:exit_status) { should eq 1 }
end
