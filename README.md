# Gitlab Pipelines TV Dashboard

## Problem

Our internal Gitlab was missing a nice, global, TV-friendly view for CI Pipelines.  
There is an [open issue](https://gitlab.com/gitlab-org/gitlab-ce/issues/3235) about it,
and a very nice mockup already:

![Mockup](https://gitlab.com/gitlab-org/gitlab-ce/uploads/2bf850dee70767bc4dac47f7d605dfd0/Artboard_1_Copy_3.png)

But the feature is tagged as a "moonshot", so not sure we'll get it baked in Gitlab soon.

## Solution

We quickly hacked together our own:

![Screenshot](/screenshot.png)

This version has only a list (polling the APIs and updating every 30 seconds) of Pipelines across the Gitlab instance,
but we are planning to implement the mockup view as well.

PRs-welcome!

## Demo

[Github-pages hosted version](https://ksf-media.github.io/gitlab-dashboard/)

You need to give to the page some parameters:
- `private_token`: your Gitlab auth token
- `gitlab_url`: the URL to your Gitlab instance

Example: `https://ksf-media.github.io/gitlab-dashboard/index.html?private_token=YOUR-TOKEN-HERE&gitlab_url=https://YOUR-GITLAB-URL`

## Developing

Install depencies with:

```bash
npm install -g pulp psc-package
npm install
```


Run `npm start` to serve a hot-reload server on http://localhost:1337/
