# owasp-security-scanner

> Provides capability to run active, passive and api scans against multiple components using owasp zap docker via command line


## Requirements

+ Docker

## Usage

Scans can be run with the following command:

``
./scripts/scan.sh {COMPONENT} {ENVIRONMENT} {SCAN}
``

See examples below:

````
./scripts/scan.sh demo localhost active
./scripts/scan.sh apple dev api
./scripts/scan.sh banana stubbed baseline
````

### Demo
To try it out, in the terminal:

````
cd id-zap-security-scanner 
./scripts/scan.sh demo localhost active
./scripts/scan.sh demo localhost baseline
````

The above pull the juice-shop docker image, start it on localhost:3000 and run an active/baseline zap scan against it.

### Components

``
banana
``

``
apple.signup | apple.signin | apple.signout
``


### Environment

For each component, the following environments have been included in the configuration

| Component | Environment           |
| ----------| ----------------------|
| Apple     | QA                    |
| Banana    | DEV                   |
| Demo      | LOCALHOST             |

### Scan
``active`` Runs an active scan against the target url defined in the env.properties for the component.

For more info: https://github.com/zaproxy/zaproxy/wiki/ZAP-Full-Scan

**WARNING:** Don't run this scan against any component deployed to any environment unless you have been asked to do so. This could potentially break the environment that is in use by others as it actively attacks the target and may run for a long period.

``baseline`` Runs a spider against the target url and then runs various passive scans until complete.

For more info: https://github.com/zaproxy/zaproxy/wiki/ZAP-Baseline-Scan

``api`` Run an active scan against the target url defined in the swagger passed in. This also runs an active scan so it is not recommended to run against deployed components. 

For more info: https://github.com/zaproxy/zaproxy/wiki/ZAP-API-Scan

### Reports
Html reports are generated in the ``reports`` directory.

### Configuration

### Config
Parameters can be passed into zap and defined in the ``config.properties`` under each component directory. A parameter may include headers and values or html IDs for input fields. If there is no ``config.properties`` in the ``configuration`` directory or it is empty then it will be ignored and the scan will be run without this. 

NOTE: Config parameters need further investigation in to how they work and how they can be used to fine tune the scan. See https://github.com/zaproxy/zaproxy/wiki/FAQconfigValues

### Rules
Rules defines how the scan runs. These can be changed to ``IGNORE`` or ``FAIL`` as required. See ``application/[COMPONENT]/rules`` directory for ``rules.config`` for each component

### Env
See ``application/[COMPONENT]/env`` for environment properties

### Progress Files
**NOTE:** These have not been included

Progress files can be used to flag issues that are already known about and are being addressed to help identify new issues

### Notes
Further work to be done:

+ Add tests using BATS - https://github.com/sstephenson/bats
+ Add progress files - see links above
+ Configure to run in pipelines or set up a nightly job to run scans for various components