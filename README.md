# kubernetes-stack-cookbook [![Build Status](https://travis-ci.org/teracyhq-incubator/kubernetes-stack-cookbook.svg?branch=develop)](https://travis-ci.org/teracyhq-incubator/kubernetes-stack-cookbook)

Kubernetes stack cookbook to work with Kubernetes

## Requirements

- Chef 12.5.x or higher. Chef 11 is NOT SUPPORTED.

## Platform support

|              | gcloud | kubectl | helm |
|--------------|:------:|:--------|:----:|
| centos-7     | ✔      | ✔       | ✔    |
| ubuntu-16.04 | ✔      | ✔       | ✔    |

- [kubectl](#kubectl): support all version with centos-7 and ubuntu-16.04.
- [helm](#helm): support all version with centos-7 and ubuntu-16.04.
- [gcloud](#gcloud): support all version with centos-7 and ubuntu-16.04. Should use version avaiable in https://packages.cloud.google.com/apt/ (with ubuntu platform) for faster autocomplete.

## How to use

- Add `depends 'kubernetes-stack'` to your cookbook's metadata.rb.
- Use the resources shipped in cookbook in a recipe :

```ruby
kubectl 'install kubectl' do
  action [:install, :remove]
  version ''
  binary_path '' #application path (if empty, default:/usr/local/bin/kubectl)
end

gcloud 'install gcloud' do
  action [:install, :remove]
  version ''
  binary_path '' #application path (if empty, default:/usr/local/bin/gcloud)
end

helm 'install helm' do
  action [:install, :remove]
  version ''
  binary_path '' #application path (if empty, default:/usr/local/bin/helm)
end
```

## How to develop

- Follow https://github.com/teracyhq/dev-setup/tree/develop

- Fork this project into the your personal account and then clone it into the workspace directory:

  ```bash
  $ cd ~/teracy-dev/workspace
  $ git checkout <your_forked_repo>
  $ cd kubernetes-stack-cookbook
  $ git remote add upstream git@github.com:teracyhq-incubator/kubernetes-stack-cookbook.git
  ```

- `$ vagrant reload --provision` to update the dev-setup from this project into the teracy-dev's VM.

- For codestyle checking:

  ```bash
  $ cd ~/teracy-dev
  $ vagrant ssh
  $ ws
  $ cd kubernetes-stack-cookbook
  $ codestyle
  ```

- For rspec checking:

  ```bash
  $ rspec
  ```

- For kitchen testing:

  ```bash
  $ kitchen list
  $ kitchen verify <instance>
  ```

## Resources overview

- [gcloud](#gcloud): install or remove `google-cloud-sdk`.
- [kubectl](#kubectl): install or remove `kubectl`.
- [helm](#helm): install or remove `helm`.

## See more:

- https://github.com/teracyhq/dev
- https://docs.chef.io/cookstyle.html
- https://github.com/chef/cookstyle
- https://github.com/someara/kitchen-dokken
- https://docs.chef.io/about_chefdk.html
- https://github.com/chef/chef-dk
- http://kitchen.ci/
