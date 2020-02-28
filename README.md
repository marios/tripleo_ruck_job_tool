## Install oooci-jobs.sh

Just download it and run it!

```
wget https://raw.githubusercontent.com/marios/tripleo_ruck_job_tool/master/oooci-jobs.sh
chmod 754 oooci-jobs.sh
[m@192 ~]$ ./oooci-jobs.sh -f -d
```

 If you like it you might consider moving it somewhere in your $PATH.


The oooci-jobs.sh script is a utility to query any tripleo-ci job
defined upstream, in RDO jobs or internal SF. Jobs are queried using a local
checkout of all relevant repos including [tripleo-ci](https:/
//github.com/openstack/tripleo-ci)
[rdo-jobs](https://github.com/rdo-infra/rdo-jobs)

Assuming you can access code.engineering.redhat. repos the --dstream|-d option
allows you to include those in a job search.

The information returned includes:
  * if the job is voting
  * a link to the relevant codesearch for the job
  * a link to the job definition
  * a link to latest zuul builds
  * if the job is in promotion criteria (when job name starts with 'periodic')

Example usage:

```
[m@192 ~]$ oooci-jobs.sh  periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky

**** oooci-jobs.sh ** 2019-06-10 17:24:56 *****************************************************************
**** Processing job: periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky

oooci-jobs.sh:  ... fetching voting info from https://review.rdoproject.org/zuul/api/job/periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   887  100   887    0     0    811      0  0:00:01  0:00:01 --:--:--   811
oooci-jobs.sh:  *** VOTING *** true
oooci-jobs.sh:  *** CODE SEARCH *** https://codesearch.rdoproject.org/?q=periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
oooci-jobs.sh:  *** DEFINITION *** https://github.com/rdo-infra/rdo-jobs/blob/master/zuul.d/ovb-jobs.yaml#L299
oooci-jobs.sh:  *** ZUUL BUILDS *** https://review.rdoproject.org/zuul/builds?job_name=periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
18:periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
oooci-jobs.sh:  *** PROMOTION CRITERIA *** NOT IN queens  ** IN rocky ** https://github.com/rdo-infra/ci-config/blob/master/ci-scripts/dlrnapi_promoter/config/CentOS-7/rocky.ini  NOT IN stein NOT IN master
oooci-jobs.sh:  *** COLLECTED URLs ***  https://review.rdoproject.org/zuul/job/periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky https://codesearch.rdoproject.org/?q=periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky https://github.com/rdo-infra/rdo-jobs/blob/master/zuul.d/ovb-jobs.yaml#L299 https://review.rdoproject.org/zuul/builds?job_name=periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky https://github.com/rdo-infra/ci-config/blob/master/ci-scripts/dlrnapi_promoter/config/CentOS-7/rocky.ini
oooci-jobs.sh:  *** Open URLs with  firefox? *** type y or yes - anything else for no > y
oooci-jobs.sh: see  firefox
oooci-jobs.sh: END periodic-tripleo-ci-centos-7-ovb-3ctlr_1comp-featureset001-rocky
```

## Usage oooci-jobs.sh

There are two main modes:

  * Single query mode - where you must specify a jobname
  * Loop mode for multiple queries which you can enable with -f or--foreva

Use --help to see the available options
```
[m@192 ]$ ./oooci-jobs.sh -h
Usage: ./oooci-jobs.sh [options] jobname
unless you specify --foreva jobname is REQUIRED

... #various options available
  -h, --help          print this help and exit
```

To include the downstream repos like code.engineering.redhat.* you need to add
the --dstream or -d flag in the query. The default is to *not* include those
in the job processing.

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
[m@192 ~]$ OOOCI_BROWSER=google-chrome oooci-jobs.sh legacy-weirdo-integration-queens-puppet-scenario003

**** oooci-jobs.sh ** 2019-06-10 17:28:05 *****************************************************************
**** Processing job: legacy-weirdo-integration-queens-puppet-scenario003

oooci-jobs.sh:  ... fetching voting info from https://review.rdoproject.org/zuul/api/job/legacy-weirdo-integration-queens-puppet-scenario003
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2220  100  2220    0     0   1118      0  0:00:01  0:00:01 --:--:--  1117
oooci-jobs.sh:  *** VOTING *** true
oooci-jobs.sh:  *** CODE SEARCH *** https://codesearch.rdoproject.org/?q=legacy-weirdo-integration-queens-puppet-scenario003
oooci-jobs.sh:  *** DEFINITION *** https://github.com/rdo-infra/rdo-jobs/blob/master/zuul.d/zuul-legacy-jobs.yaml#L853
oooci-jobs.sh:  *** ZUUL BUILDS *** https://review.rdoproject.org/zuul/builds?job_name=legacy-weirdo-integration-queens-puppet-scenario003
oooci-jobs.sh:  *** COLLECTED URLs ***  https://review.rdoproject.org/zuul/job/legacy-weirdo-integration-queens-puppet-scenario003 https://codesearch.rdoproject.org/?q=legacy-weirdo-integration-queens-puppet-scenario003 https://github.com/rdo-infra/rdo-jobs/blob/master/zuul.d/zuul-legacy-jobs.yaml#L853 https://review.rdoproject.org/zuul/builds?job_name=legacy-weirdo-integration-queens-puppet-scenario003
oooci-jobs.sh:  *** Open URLs with google-chrome? *** type y or yes - anything else for no > y
oooci-jobs.sh: see google-chrome
[16867:16867:0610/172816.502231:ERROR:sandbox_linux.cc(368)] InitializeSandbox() called with multiple threads in process gpu-process.
[16822:16847:0610/172816.525150:ERROR:browser_process_sub_thread.cc(221)] Waited 7 ms for network service
Opening in existing browser session.
oooci-jobs.sh: END legacy-weirdo-integration-queens-puppet-scenario003
```

A parameter can be added to override instead of using the OOOCI_BROWSER shell variable if that is requested.
