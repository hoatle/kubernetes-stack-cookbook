
describe command('which gcloud') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match('/usr/bin/gcloud') }
end
