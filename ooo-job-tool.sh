jobname=""
LOCAL_REPOS_DIR=${LOCAL_REPOS_DIR:-$HOME/Downloads/ooo-job-tool}
JOB_REPOS=(
https://github.com/openstack/tripleo-ci.git
https://github.com/rdo-infra/rdo-jobs.git
https://github.com/rdo-infra/ci-config.git
)
BRANCHES=(
queens
rocky
stein
master
)

function purty_print {
  echo "tripleo-ci-tool: $1"
}

function clean_repo {
  local repo_dir=$1
  pushd $repo_dir
  purty_print "PULLING LATEST $repo_dir"
  git checkout master && git pull
  popd
}

function setup_repos {
  purty_print "STARTING SETUP"
  mkdir $LOCAL_REPOS_DIR || true
  pushd $LOCAL_REPOS_DIR
  for repo in ${JOB_REPOS[@]}; do
    local local_dir=$(basename $repo .git)
    purty_print "CHECKING REPO $local_dir"
    if [[ -d $local_dir ]]; then
        clean_repo $local_dir
    else
       purty_print "CLONING $repo"
       git clone $repo
    fi
  done
  popd
  purty_print "SETUP DONE"
}

function check_voting {
  local jobname=$1
  local repo=$2

  case "$repo" in
    *tripleo-ci*)
      local uri="http://zuul.openstack.org/api/job/$jobname"
      purty_print " ... fetching voting info from $uri"
      local voting=$(curl $uri | jq '.[] | .voting')
      ;;
    *rdo-jobs*)
      local uri="https://review.rdoproject.org/zuul/api/job/$jobname"
      purty_print " ... fetching voting info from $uri"
      local voting=$(curl $uri | jq '.[] | .voting')
      ;;
  esac
  purty_print "$jobname is voting: $voting"
}

function get_job_uri {
  local repo=$1
  local jobpath=$2
  local jobname=$3
  local filename=$4
  local linenumber=$5

  # https://github.com/openstack/tripleo-ci/blob/master/zuul.d/standalone-jobs.yaml#L87
  local job_uri="${repo::-4}/blob/master/$jobpath#L$linenumber"
  purty_print "$jobname DEFINITION $job_uri"
  #$BROWSER $job_uri
}

function get_zuul_builds_uri {
  local jobname=$1
  local repo=$2
  case "$repo" in
    *tripleo-ci*)
      local zuul_builds="http://zuul.openstack.org/builds?job_name=$jobname"
      ;;
    *rdo-jobs*)
      local zuul_builds="https://review.rdoproject.org/zuul/builds?job_name=$jobname"
      ;;
  esac
  purty_print "$jobname ZUUL BUILDS $zuul_builds"
}

# use local checkout vs curl the promotion file each time?
function get_job_promotion_status {
  local jobname=$1
  local promotion_file_path="$LOCAL_REPOS_DIR/ci-config/ci-scripts/dlrnapi_promoter/config/CentOS-7"
  local promotion_file_uri="https://github.com/rdo-infra/ci-config/blob/master/ci-scripts/dlrnapi_promoter/config/CentOS-7"

  for branch in ${BRANCHES[@]}; do
    if grep -rni "^$jobname$" $promotion_file_path/$branch.ini ; then
      purty_print "$jobname PROMOTION CRITERIA $branch - $promotion_file_uri/$branch.ini"
    fi
  done
}


# check if voting and echo the definition and pointer to opendev.org
function process_job_definition {
  local jobname=$1
  for repo in ${JOB_REPOS[@]}; do
    local local_dir=$(basename $repo .git)
    local res=$(grep -rni "name\: $jobname$" $LOCAL_REPOS_DIR/$local_dir)
    if [[ -n "$res" ]]; then
      local filename=$(echo $res | awk -F ":" '{print $1}')
      local linenumber=$(echo $res | awk -F ":" '{print $2}')
      check_voting $jobname $repo
      case "$repo" in
        *tripleo-ci*)
          local jobpath=$(echo $filename | awk -F "/tripleo-ci/" '{print $2}')
          ;;
        *rdo-jobs*)
          local jobpath=$(echo $filename | awk -F "/rdo-jobs/" '{print $2}')
          ;;
      esac
      get_job_uri $repo $jobpath $jobname $filename $linenumber
      get_zuul_builds_uri $jobname $repo
      if [[ $jobname =~ "periodic" ]] ; then
        get_job_promotion_status $jobname
      fi
    fi
    unset res
  done
}


setup_repos
while [[ $jobname != "exit" ]] ; do
    echo -n "it puts the job name here: "
    read jobname
    process_job_definition $jobname
done
