# Gitlab Pipelines TV Dashboard

## Problem

Our internal Gitlab was missing a nice, global, TV-friendly view for CI Pipelines.  
There is an [open issue](https://gitlab.com/gitlab-org/gitlab-ce/issues/3235) about it,
and a very nice mockup already:

![Mockup](https://gitlab.com/gitlab-org/gitlab-ce/uploads/2bf850dee70767bc4dac47f7d605dfd0/Artboard_1_Copy_3.png)

But the feature is tagged as a "moonshot", so not sure we'll get it baked in Gitlab soon.

## Solution

We made a simple dashboard that lists all CI builds, together with their status, completion time, etc:

![Screenshot](/screenshot.png)

We currently list _all_ the Pipelines on _all_ branches (polling the APIs and updating every 30s),
but we'd like to implement also a simpler view that tracks the status of the `master` branch.  
This effort is tracked [here](https://github.com/KSF-Media/gitlab-dashboard/issues/13).

We very much welcome PRs, if you'd like to contribute take a look at the [issue list](https://github.com/KSF-Media/gitlab-dashboard/issues)
for Issues tagged with "Good first issue"!

## Demo

[Github-pages hosted version](https://ksf-media.github.io/gitlab-dashboard/)

You need to give to the page some parameters:
- `private_token`: your Gitlab auth token
- `gitlab_url`: the URL to your Gitlab instance

Example: `https://ksf-media.github.io/gitlab-dashboard/index.html?private_token=YOUR-TOKEN-HERE&gitlab_url=https://YOUR-GITLAB-URL`

## Developing

Quickstart:
- Install [yarn](https://yarnpkg.com/lang/en/docs/install/)
- Install [spago](https://github.com/purescript/spago.git)
- `yarn install -E`
- `yarn build`
- Open `file://path/to/gitlab-dashboard/index.html?private_token=<gitlabtoken>&gitlab_url=https://gitlab.domain.tld` in a browser

## Docker

Build image
    docker build -t gitlab-dashboard:latest .
Run the server
    docker run -t -p 80:80 --rm gitlab-dashboard
