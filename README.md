## README oooci-jobs.sh

The oooci-jobs.sh script is meant as a utility tool to query any tripleo-ci job
defined upstream, in RDO jobs or internal SF. Jobs are queryied using local
checkout of repos including [tripleo-ci](https://github.com/openstack/tripleo-ci)
[rdo-jobs](https://github.com/rdo-infra/rdo-jobs) and
[tripleo-ci-internal-jobs](https://code.engineering.redhat.com/gerrit/#/admin/projects/openstack/tripleo-ci-internal-jobs).

The information returned includes whether the job is voting, a link to the
job definition and latest zuul builds, and if it is periodic, whether the
job is in promotion criteria.

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

The entire script is in one file. Just download it and run it!

```
[m@192 ~]$ wget https://raw.githubusercontent.com/marios/tripleo_ruck_job_tool/master/oooci-jobs.sh
[m@192 ~]$ chmod 754 oooci-jobs.sh
[m@192 ~]$ ./oooci-jobs.sh
./oooci-jobs.sh: ERROR: you must either specify a job name or pass --foreva
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

## Run oooci-jobs.sh

There are two main modes. Single query mode - where you must specify a jobname.
There is also a loop mode for multiple queries which you can enable with -f or
--foreva.

On first run or the first time you query for a job you will see an error if any
of the expected local repos are missing

```
[m@192 ]$ ./oooci-jobs.sh tripleo-ci-rhel-8-standalone-rhos-15

**** ./oooci-jobs.sh ** 2019-05-31 15:25:17 *****************************************************************
**** Processing job: tripleo-ci-rhel-8-standalone-rhos-15

./oooci-jobs.sh: ERROR: https://github.com/openstack/tripleo-ci.git local checkout not found at /home/m/Downloads/oooci-jobs/tripleo-ci
./oooci-jobs.sh: Run ./oooci-jobs.sh --refresh tripleo-ci-rhel-8-standalone-rhos-15 to setup local repos required for job query

```

You can re-run with --refresh in order to setup the local checkouts required
for subsequent runs. After you are setup, --refresh can be used at will in
order to update the local repo checkouts.

Note that running with --foreva will first also call the repo setup.

```
[m@192 tripleo_ruck_job_tool]$ ./oooci-jobs.sh -f

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

./oooci-jobs.sh:  ... fetching voting info from http://zuul.openstack.org/api/job/tripleo-ci-centos-7-scenario012-standalone
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1838  100  1838    0     0   2621      0 --:--:-- --:--:-- --:--:--  2618
./oooci-jobs.sh: job is voting: false
./oooci-jobs.sh: job DEFINITION https://github.com/openstack/tripleo-ci/blob/master/zuul.d/standalone-jobs.yaml#L624
./oooci-jobs.sh: job ZUUL BUILDS http://zuul.openstack.org/builds?job_name=tripleo-ci-centos-7-scenario012-standalone

**** ./oooci-jobs.sh ** 2019-05-31 15:34:22 *****************************************************************
**** main loop - ctrl-c or 'exit' to exit

./oooci-jobs.sh: it puts the job name here >
```
