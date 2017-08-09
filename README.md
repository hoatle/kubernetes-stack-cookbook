# kubernetes-stack-cookbook [![Build Status](https://travis-ci.org/teracyhq-incubator/kubernetes-stack-cookbook.svg?branch=develop)](https://travis-ci.org/teracyhq-incubator/kubernetes-stack-cookbook)

Kubernetes stack cookbook to work with Kubernetes


## How to use

//TODO


## Getting started

- Follow https://github.com/teracyhq/dev-setup/tree/develop

- Fork this project into the your personal account and then clone it into the workspace directory:

  ```bash
  $ cd ~/teracy-dev/workspace
  $ git checkout <your_forked_repo>
  $ cd kubernetes-stack-cookbook
  $ git remote add upstream git@github.com:teracyhq-incubator/kubernetes-stack-cookbook.git
  ```

- `$ vagrant reload --provision` to update the dev-setup from this project into the teracy-dev's VM.
  After that, you should be ready to work on the project.

## How to develop

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

## See more:

- https://github.com/teracyhq/dev
- https://docs.chef.io/cookstyle.html
- https://github.com/chef/cookstyle
- https://github.com/someara/kitchen-dokken
- https://docs.chef.io/about_chefdk.html
- https://github.com/chef/chef-dk
- http://kitchen.ci/
