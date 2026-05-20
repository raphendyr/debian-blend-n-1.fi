# N-1 Meta packages

## Required Packages

To compile and maintain this blend, install the following packages:

    sudo apt-get install devscripts blends-dev dupload dpkg-dev


## Maintenance Workflow

### Update the Changelog

To increment the package version or document modifications:

    dch

### Build the Package Metadata

To generate updated system task definitions:

    make dist


## Local Testing & Deployment Workflow

### Build, Index, and Deploy Locally

Whenever you make a change and want to test it immediately, run the following command. This automatically fires `debuild`, copies the fresh `.deb` binaries into the local staging folder, rebuilds the package dependency indexes, and triggers an `apt update`:

    make deploy-local


### Install Blend Tasks

Once the deployment script finishes successfully, you can launch the native interactive selection menu:

    sudo tasksel

Or you can install a specific target blend component directly through the command line:

    sudo tasksel install blend-n-1.fi-desktop
