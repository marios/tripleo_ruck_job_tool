## README oooci-jobs.sh

The oooci-jobs.sh script is a utility to query any tripleo-ci job
defined upstream, in RDO jobs or internal SF. Jobs are queried using a local
checkout of all relevant repos including [tripleo-ci](https://github.com/openstack/tripleo-ci)
[rdo-jobs](https://github.com/rdo-infra/rdo-jobs) and
[tripleo-ci-internal-jobs](https://code.engineering.redhat.com/gerrit/#/admin/projects/openstack/tripleo-ci-internal-jobs).
For this reason, at least during initial setup when repos are locally cloned, you will need
to have RH VPN access to reach code.engineering.redhat.com.

The information returned includes:
  * if the job is voting
  * a link to the job definition
  * a link to latest zuul builds
  * if the job is in promotion criteria (when job name starts with 'periodic')

Example usage:

```
[m@192 tripleo_ruck_job_tool]$ ./oooci-jobs.sh  periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky


**** ./oooci-jobs.sh ** 2019-05-31 15:05:59 *****************************************************************
**** Processing job: periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky

./oooci-jobs.sh:  ... fetching voting info from https://review.rdoproject.org/zuul/api/job/periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   862  100   862    0     0    420      0  0:00:02  0:00:02 --:--:--   420
./oooci-jobs.sh: job is voting: true
./oooci-jobs.sh: job DEFINITION https://github.com/rdo-infra/rdo-jobs/blob/master/zuul.d/ovb-jobs.yaml#L370
DEBUG https://review.rdoproject.org/zuul/builds?job_name=periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
./oooci-jobs.sh: job ZUUL BUILDS https://review.rdoproject.org/zuul/builds?job_name=periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
./oooci-jobs.sh: Checking if job is in promotion criteria
18:periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
./oooci-jobs.sh: job NOT IN queens  *** IN rocky CRITERIA https://github.com/rdo-infra/ci-config/blob/master/ci-scripts/dlrnapi_promoter/config/CentOS-7/rocky.ini *** NOT IN stein NOT IN master

```

## Install oooci-jobs.sh

Just download it and run it!

```
wget https://raw.githubusercontent.com/marios/tripleo_ruck_job_tool/master/oooci-jobs.sh
chmod 754 oooci-jobs.sh
[m@192 ~]$ ./oooci-jobs.sh
```

 If you like it you might consider moving it somewhere in your $PATH.

## Usage oooci-jobs.sh

There are two main modes:

  * Single query mode - where you must specify a jobname
  * Loop mode for multiple queries which you can enable with -f or--foreva

Use --help to see the available options
```
[m@192 ]$ ./oooci-jobs.sh -h
Usage: ./oooci-jobs.sh [options] jobname
unless you specify --foreva jobname is REQUIRED

Options:
  -r, --refresh
                      Create git clone of any missing jobs repos into
                      /home/m/Downloads/oooci-jobs and fetch changes from master
  -p, --path
                      Sets the local path for git cloning repos into.
                      Defaults to /home/m/Downloads/oooci-jobs.
  -f, --foreva
                      Runs in a loop for multiple queries. It will
                      first also refresh repos.
  -h, --help          print this help and exit
```

### First run and repo setup

Unless you use the --foreva mode which always runs the repo setup, the first time you query for a job you will see an error for any missing local repo checkouts. 

```
[m@192 ]$ ./oooci-jobs.sh tripleo-ci-rhel-8-standalone-rhos-15

**** ./oooci-jobs.sh ** 2019-05-31 15:25:17 *****************************************************************
**** Processing job: tripleo-ci-rhel-8-standalone-rhos-15

./oooci-jobs.sh: ERROR: https://github.com/openstack/tripleo-ci.git local checkout not found at /home/m/Downloads/oooci-jobs/tripleo-ci
./oooci-jobs.sh: Run ./oooci-jobs.sh --refresh tripleo-ci-rhel-8-standalone-rhos-15 to setup local repos required for job query

```
Re-run and include the --refresh flag in order to setup the local repo checkouts before
performing the requested job query. The --path flag overrides the local repo checkout
location, which defaults to $HOME/Downloads/oooci-jobs/. 

After all required repos are cloned, --refresh can be used as needed in order to update the local
repo checkouts.

Note that running with --foreva will first also call the repo setup.

```
[m@192 tripleo_ruck_job_tool]$ ./oooci-jobs.sh --foreva

**** ./oooci-jobs.sh ** 2019-05-31 15:32:27 *****************************************************************
**** Starting local git clones setup or refresh

./oooci-jobs.sh: PULLING tripleo-ci
Already up to date.
./oooci-jobs.sh: PULLING rdo-jobs
Already up to date.
./oooci-jobs.sh: PULLING ci-config
Already up to date.
./oooci-jobs.sh: PULLING review.rdoproject.org-config
Already up to date.
./oooci-jobs.sh: PULLING tripleo-ci-internal-config
Already up to date.
./oooci-jobs.sh: PULLING tripleo-ci-internal-jobs
Already up to date.
./oooci-jobs.sh: SETUP DONE

**** ./oooci-jobs.sh ** 2019-05-31 15:32:42 *****************************************************************
**** main loop - ctrl-c or 'exit' to exit

./oooci-jobs.sh: it puts the job name here > tripleo-ci-centos-7-scenario012-standalone

**** ./oooci-jobs.sh ** 2019-05-31 15:34:21 *****************************************************************
**** Processing job: tripleo-ci-centos-7-scenario012-standalone
```

After processing a job there is a prompt for opening in browser - expected input is 'y' or 'yes' otherwise no
is assumed. The variable $OOOCI_BROWSER defaults to firefox though you can set it before running to override:

```
[m@192 tripleo_ruck_job_tool]$ OOOCI_BROWSER=google-chrome oooci-jobs.sh legacy-weirdo-integration-queens-puppet-scenario003

**** oooci-jobs.sh ** 2019-06-03 17:38:28 *****************************************************************
**** Processing job: legacy-weirdo-integration-queens-puppet-scenario003 

oooci-jobs.sh:  ... fetching voting info from https://review.rdoproject.org/zuul/api/job/legacy-weirdo-integration-queens-puppet-scenario003
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2195  100  2195    0     0   1608      0  0:00:01  0:00:01 --:--:--  1608
oooci-jobs.sh: job is voting: true
oooci-jobs.sh: job DEFINITION https://github.com/rdo-infra/rdo-jobs/blob/master/zuul.d/zuul-legacy-jobs.yaml#L853
oooci-jobs.sh: job ZUUL BUILDS https://review.rdoproject.org/zuul/builds?job_name=legacy-weirdo-integration-queens-puppet-scenario003
oooci-jobs.sh: Does it want it in the browser? type y or yes - anything else for no > y
oooci-jobs.sh: see google-chrome
```
A parameter can be added to override instead of using the OOOCI_BROWSER shell variable if that is requested.
