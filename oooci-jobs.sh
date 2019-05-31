OOOCI_REPOS_PATH=${OOOCI_REPOS_PATH:-$HOME/Downloads/oooci-jobs}
REFRESH=0
FOREVA=0

JOB_REPOS=(
https://github.com/openstack/tripleo-ci.git
https://github.com/rdo-infra/rdo-jobs.git
https://github.com/rdo-infra/ci-config.git
https://github.com/rdo-infra/review.rdoproject.org-config.git
https://code.engineering.redhat.com/gerrit/openstack/tripleo-ci-internal-config.git
https://code.engineering.redhat.com/gerrit/openstack/tripleo-ci-internal-jobs.git
)
BRANCHES=(
queens
rocky
stein
master
)

function purty_print {
  echo "$0: $1"
}

function print_section_line {
  echo "**** $0 ** $(date '+%Y-%m-%d %H:%M:%S') *****************************************************************"
}

function purty_print_section {
  echo ""
  print_section_line
  echo "**** $1 "
  echo ""
}

function clean_repo {
  local repo_dir=$1
  pushd $repo_dir > /dev/null 2>&1
  purty_print "PULLING $repo_dir"
  git checkout master > /dev/null 2>&1
  git pull
  popd > /dev/null 2>&1
}

function setup_repos {
  purty_print_section "Starting local git clones setup or refresh"
  mkdir -p $OOOCI_REPOS_PATH
  pushd $OOOCI_REPOS_PATH  > /dev/null 2>&1
  for repo in ${JOB_REPOS[@]}; do
    local local_dir=$(basename $repo .git)
    if [[ -d $local_dir ]]; then
        clean_repo $local_dir
    else
       purty_print "CLONING $repo"
       git clone $repo
    fi
  done
  popd  > /dev/null 2>&1
  purty_print "SETUP DONE"
}

function check_voting {
  local jobname=$1
  local repo=$2

  case "$repo" in
    *tripleo-ci.git)
      local uri="http://zuul.openstack.org/api/job/$jobname"
      ;;
    *review.rdoproject.org-config.git|*rdo-jobs.git)
      local uri="https://review.rdoproject.org/zuul/api/job/$jobname"
      ;;
    *tripleo-ci-internal*)
      local uri="https://sf.hosted.upshift.rdu2.redhat.com/zuul/api/tenant/tripleo-ci-internal/job/$jobname"
      ;;
  esac
  purty_print " ... fetching voting info from $uri"
  local voting=$(curl -k $uri | jq '.[] | .voting')
  purty_print "job is voting: $voting"
}

function get_job_uri {
  local repo=$1
  local jobpath=$2
  local jobname=$3
  local filename=$4
  local linenumber=$5

  # https://github.com/openstack/tripleo-ci/blob/master/zuul.d/standalone-jobs.yaml#L87
  # https://code.engineering.redhat.com/gerrit/gitweb?p=openstack/tripleo-ci-internal-jobs.git;a=blob;f=zuul.d/standalone-jobs.yaml#l80
  case "$repo" in
    *tripleo-ci-internal*)
      local internal_base_uri="https://code.engineering.redhat.com/gerrit/gitweb?p=openstack"
      local job_uri="$internal_base_uri/$(basename $repo);a=blob;f=$jobpath#l$linenumber"
      ;;
    *)
      local job_uri="${repo::-4}/blob/master/$jobpath#L$linenumber"
  esac
  purty_print "job DEFINITION $job_uri"
}

function get_zuul_builds_uri {
  local jobname=$1
  local repo=$2
  case "$repo" in
    *tripleo-ci.git)
      local zuul_builds="http://zuul.openstack.org/builds?job_name=$jobname"
      ;;
    *rdo-jobs.git|*review.rdoproject.org-config.git)
      local zuul_builds="https://review.rdoproject.org/zuul/builds?job_name=$jobname"
      echo "DEBUG $zuul_builds"
      ;;
    *tripleo-ci-internal*)
      local zuul_builds="https://sf.hosted.upshift.rdu2.redhat.com/zuul/t/tripleo-ci-internal/builds?job_name=$jobname"
      ;;
  esac
  purty_print "job ZUUL BUILDS $zuul_builds"
}

# use local checkout vs curl the promotion file each time?
function get_job_promotion_status {
  local jobname=$1
  local promotion_file_path="$OOOCI_REPOS_PATH/ci-config/ci-scripts/dlrnapi_promoter/config/CentOS-7"
  local promotion_file_uri="https://github.com/rdo-infra/ci-config/blob/master/ci-scripts/dlrnapi_promoter/config/CentOS-7"
  purty_print "Checking if job is in promotion criteria"
  local res=""
  for branch in ${BRANCHES[@]}; do
    if grep -rni "^$jobname$" $promotion_file_path/$branch.ini ; then
      local res+=" *** IN $branch CRITERIA $promotion_file_uri/$branch.ini *** "
    else
      local res+="NOT IN $branch "
    fi
  done
  purty_print "job $res"
}

# check if voting and echo the definition and pointer to opendev.org
function process_job_definition {
  local jobname=$1
  purty_print_section "Processing job: $jobname"
  for repo in ${JOB_REPOS[@]}; do
    local local_dir=$(basename $repo .git)
    if [[ ! -d $OOOCI_REPOS_PATH/$local_dir ]]; then
      purty_print "ERROR: $repo local checkout not found at $OOOCI_REPOS_PATH/$local_dir"
      purty_print "Run $0 --refresh $jobname to setup local repos required for job query"
      exit 2
    fi
    local res=$(grep -rni "name\: $jobname$" $OOOCI_REPOS_PATH/$local_dir)
    if [[ -n "$res" ]]; then
      local filename=$(echo $res | awk -F ":" '{print $1}')
      local linenumber=$(echo $res | awk -F ":" '{print $2}')
      check_voting $jobname $repo
      case "$repo" in
        *tripleo-ci.git)
          local jobpath=$(echo $filename | awk -F "/tripleo-ci/" '{print $2}')
          ;;
        *rdo-jobs.git)
          local jobpath=$(echo $filename | awk -F "/rdo-jobs/" '{print $2}')
          ;;
        *review.rdoproject.org-config.git)
          local jobpath=$(echo $filename | awk -F "/review.rdoproject.org-config/" '{print $2}')
          ;;
        *ci-config*)
          local jobpath=$(echo $filename | awk -F "/ci-config/" '{print $2}')
          ;;
        *tripleo-ci-internal-config.git)
          local jobpath=$(echo $filename | awk -F "/tripleo-ci-internal-config/" '{print $2}')
          ;;
        *tripleo-ci-internal-jobs.git)
          local jobpath=$(echo $filename | awk -F "/tripleo-ci-internal-jobs/" '{print $2}')
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

oooci_jobs_usage () {
    echo "Usage: $0 [options] jobname"
    echo "unless you specify --foreva jobname is REQUIRED"
    echo ""
    echo "Options:"
    echo "  -r, --refresh"                                                     
    echo "                      Create git clone of any missing jobs repos into"
    echo "                      $OOOCI_REPOS_PATH and fetch changes from master"
    echo "  -p, --path"
    echo "                      Sets the local path for git cloning repos into."
    echo "                      Defaults to $OOOCI_REPOS_PATH."
    echo "  -f, --foreva"
    echo "                      Runs in a loop for multiple queries. It will"
    echo "                      first also refresh repos."
    echo "  -h, --help          print this help and exit"
}

set -e

# Input argument assignments
while [ "x$1" != "x" ]; do

    case "$1" in
        --refresh|-r)
            # realpath fails if /some/path doesn't exist. It is created later
            REFRESH=1
            ;;

        --path|-p)
            OOOCI_REPOS_PATH=$2
            shift
            ;;

        --foreva|-f)
            FOREVA=1
            ;;

        --help|-h)
            oooci_jobs_usage
            exit
            ;;

        --) shift
            break
            ;;

        -*) echo "ERROR: unknown option: $1" >&2
            oooci_jobs_usage >&2
            exit 2
            ;;

        *)    break
            ;;
    esac

    shift
done

if [[ "$REFRESH" == "1" ]] || [[ "$FOREVA" == "1" ]]; then
  setup_repos
fi
if [[ "$FOREVA" == "1" ]]; then
  while [[ $jobname != "exit" ]] ; do
    purty_print_section "main loop - ctrl-c or 'exit' to exit"
    echo -n "$0: it puts the job name here > "
    read jobname
    process_job_definition $jobname
  done
elif [[ $# != 1 ]] ; then
  if [[ "$REFRESH" == "1" ]]; then exit 0; fi # ok if refresh
  purty_print "ERROR: you must either specify a job name or pass --foreva"
  oooci_jobs_usage
  exit 2
else
  process_job_definition $1
fi
