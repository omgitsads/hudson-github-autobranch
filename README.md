# Jenkins/Hudson Github Auto-Branch

Autobranch Jenkins/Hudson jobs using Github Post-Receive hooks.

This is a sinatra application. It receives Github Post Commit Hooks and:

* when a new commit is pushed to a branch, it runs the Jenkins Jobs for this branch
* when a new branch is created, it sets up Jenkins Jobs for the new branch based on the existing Jenkins Jobs
* when a branch is deleted, it deletes the Jenkins Jobs running this branch

## Setup

1 - Clone the project from github, create config.yml based on [config.sample.yml](https://github.com/versapay/hudson-github-autobranch/blob/master/config.sample.yml).

2 - Commit your configuration file and deploy the app (Heroku is your friend).

3 - Setup github post-commit hook with the github_token you specified in your config.yml file.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## License

MIT

## Copyright

Copyright (c) 2010 Versapay, Philippe Creux. See LICENSE for details.

