/// Utils

// Credit: https://stackoverflow.com/questions/14446511
function group_by(list, keyGetter) {
  const map = new Map();
  list.forEach((item) => {
    const key = keyGetter(item);
    const collection = map.get(key);
    if (!collection) {
      map.set(key, [item]);
    } else {
      collection.push(item);
    }
  });
  return map;
}

function format_time(milliseconds) {
  // Formats time in hh:mm:ss format
  return moment("2015-01-01")
    .startOf('day')
    .milliseconds(milliseconds)
    .format('HH:mm:ss');
}


/// Constants
row_colors = {
  "running":  "bg-primary",
  "pending":  "bg-info",
  "success":  "bg-success",
  "failed":   "bg-danger",
  "canceled": "bg-warning",
  "skipped":  "bg-none" // bogus color
};


/// HTML business
function wrap_cell(val) {
  return "<td>" + val + "</td>";
}

function author_img(url) {
  return '<img src="' + url + '" height="20" width="20">';
}

function format_pipeline(pipeline) {
  var wrap_row = val => "<tr class='" + row_colors[pipeline.status] + "'>" + val + "</tr>";
  var cells = [
    "#" + pipeline.id + ": " + pipeline.status,
    pipeline.repo,
    pipeline.ref + ", " + pipeline.commit + " " + author_img(pipeline.author_img),
    pipeline.stages,
    pipeline.created + ", " + pipeline.running_time
  ];

  return wrap_row(cells.map(wrap_cell));
}


/// Data-transformation from Gitlab format to our format
function get_unique_stages (pipeline_jobs) {
  let asc_by_id = (ja, jb) => ja.id - jb.id;
  let stages_map = group_by(pipeline_jobs, stage => stage.name);
  return Array
    .from(stages_map.values())
    .map(stages => stages
         .sort(asc_by_id)
         .slice(-1)[0])  // Take last job here
    .sort(asc_by_id)
    .map(job => job.status);
}

function processJobs() {
  pipelines = [];
  var currentPipelines = group_by(jobs, j => j.pipeline.id);
  for (var [id, p] of currentPipelines.entries()) {
    started  = new Date(Math.min.apply(null, p.map(job => new Date(job.started_at))));
    finished = new Date(Math.max.apply(null, p.map(job => new Date(job.finished_at))));
    pipelines.push({
      "author_img": p[0].user.avatar_url,
      "commit": p[0].commit.title,
      "ref": p[0].ref,
      "created": moment(p[0].created_at).fromNow(),
      "status": p[0].pipeline.status,
      "id": p[0].pipeline.id,
      "repo": p[0].project,
      "stages": get_unique_stages(p),
      "running_time": format_time(Math.round(Math.abs(finished - started)))
    });
    // Add rows to page
    $("#pipelines")
      .empty()
      .append(pipelines.slice(0, 50).map(format_pipeline));
  }
}


/// API calls
function get_projects(base_url, token, callback) {
  $.getJSON(base_url + "/api/v4/projects?private_token=" +
            token + "&simple=true&per_page=20&order_by=last_activity_at",
            callback);
}

function get_jobs(base_url, token, project_id, callback) {
  $.getJSON(base_url + "/api/v4/projects/" +
            project_id + "/jobs?private_token=" +
            token + "&per_page=100",
            callback);
}


/// Polling functions
function process_projects(gitlab_url, token, projects) {
  // Callback for after we get most recent projects.
  // If we have elements in the list we reduce on the list while leaving 1 sec
  // between requests to not hammer the server.
  // Once the list is empty, we call the job processing function.
  if (projects.length > 0) {
    var project = projects[0];
    var id = project.id;
    console.log("Fetching jobs for project " + id);
    get_jobs(gitlab_url, token, id, new_jobs => {
      jobs = jobs.concat(new_jobs.map(job => {
        job.project = project.name;
        return job;
      }));
    });
    setTimeout(() => process_projects(gitlab_url, token, projects.slice(1)), 1000);
  } else {
    processJobs();
  }
}

function fetch_projects(gitlab_url, token) {
  // Refresh projects every 30 secs
  console.log("Refreshing pipelines...");
  jobs = [];
  get_projects(gitlab_url, token, projects => process_projects(gitlab_url, token, projects));
  setTimeout(() => fetch_projects(gitlab_url, token), 30000);
}


/// Check for secrets and startup polling
$(function() {
  var url = new URL(window.location.toString());
  var private_token = url.searchParams.get("private_token"),
      gitlab_url = url.searchParams.get("gitlab_url");
  if (private_token && gitlab_url) {
    fetch_projects(gitlab_url, private_token);
  } else {
    $(".app").html('<div class="alert alert-danger" role="alert">Please add gitlab_url and private_token parameters to the URL.</div>');
  }
});
