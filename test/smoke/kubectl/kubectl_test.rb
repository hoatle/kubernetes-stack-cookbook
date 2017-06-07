
describe command('which kubectl') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match('/usr/local/bin/kubectl') }
end
