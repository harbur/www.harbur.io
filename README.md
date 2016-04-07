# Harbur Landing Page

Technology:

* [Hugo](http://gohugo.io/) will generate the static website.
* [BitBucket](https://bitbucket.org/) hosts the sources in git  (unlimited private repos included in free tier).
* [CodeShip](https://codeship.com/) runs hugo on new commits and updloads (5 projects / 100 builds/month included in free tier).
* [Amazon S3](http://aws.amazon.com/s3/) hosts the static content (pennies / GB)

## Authorization Flow

At [BitBucket](https://bitbucket.org/) there is a `harbur_ci` account (with email `contact@harbur.io`) which is member of the `CI` group (of the `Harbur` team) which has `READ` privileges of all `Harbur` repositories.

At [Amazon IAM](http://aws.amazon.com/iam/) there is a `codeship` user created with “Inline Policy” the one described below, that can access `www.harbur.io` bucket.

So the connecting dots are the following:

* [CodeShip](https://codeship.com/) is connected to [BitBucket](https://bitbucket.org/) using the `harbur_ci` account to read repositories.
* [CodeShip](https://codeship.com/) is connected to  [Amazon](http://aws.amazon.com/) using the `codeship` account to sync the S3 Bucket `www.harbur.io`.

## Manually publishing Hugo blogs to S3

In order to push the hugo content directly to S3 from CLI, use the following command ('s3cmd' should be installed and configured properly):

```
s3cmd put -P --recursive public/ s3://www.harbur.io
```

## Automatically publishing Hugo blogs to S3

The configuration is inspired by https://loads.pickle.me.uk/2015/07/25/hugo-s3-hosting/


##

The process traditionally is:

create a new blog article, edit it some, save.
run hugo on the command line to generate the static site.
copy/sync the public directory onto your webserver.
Needing a webserver, build environment and text editor is a bit of hassle. It’s all a bit manual too. I’ve previously blogged about hosting on S3, but I wanted to see if a static blog could be managed entirely on free/hosted services.

This post was inspired by: http://discuss.gohugo.io/t/my-deployment-process/807. I switched out a couple of the services to match my choices.

Technology

Hugo will generate your static blog (free, open source!)
Bitbucket hosts the sources in git (unlimited private repos included in free tier)
Codeship runs hugo on new commits and uploads (5 projects / 100 builds/month included in free tier)
Amazon S3 hosts the static content (pennies / GB)
1. Setting up Hugo

Follow the Hugo quickstart and create a blog with some content.

You’ll also want to add a script to install the hugo binary on the build server:

#!/bin/bash -ex
HUGO_VERSION=0.14
wget https://github.com/spf13/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux_amd64.tar.gz
tar xvzf hugo_${HUGO_VERSION}_linux_amd64.tar.gz
cp hugo_${HUGO_VERSION}_linux_amd64/hugo_${HUGO_VERSION}_linux_amd64 hugo
Save this as scripts/install-hugo.sh and chmod +x scripts/install-hugo.sh.

2. Create a Bitbucket repository

Sign up to a Bitbucket account, create a new empty repository ‘myblog’ and follow the steps to upload your blog from above to push it up to Bitbucket.

3. Setup Amazon S3

Signing up for Amazon webservices is a fairly involved process. Left as an exercise for the reader :-)
In the S3 section of the console create your new bucket ‘mybucket’, and enable “Static Website Hosting”.
We want to create a user just allowing Codeship to upload to this bucket - in “Identity & Access Management”->Users, Create a new user, keeping the Access Key and Secure Key safe for later, and set an “Inline Policy” on this user to:
	{
	    "Version": "2012-10-17",
	    "Statement": [
	        {
	            "Effect": "Allow",
	            "Action": [
	                "s3:ListBucket"
	            ],
	            "Resource": [
	                "arn:aws:s3:::mybucket"
	            ]
	        },
	        {
	            "Effect": "Allow",
	            "Action": [
	                "s3:AbortMultipartUpload",
	                "s3:DeleteObject",
	                "s3:DeleteObjectVersion",
	                "s3:GetObject",
	                "s3:GetObjectAcl",
	                "s3:GetObjectVersion",
	                "s3:GetObjectVersionAcl",
	                "s3:PutObject",
	                "s3:PutObjectAcl",
	                "s3:PutObjectAclVersion"
	            ],
	            "Resource": [
	                "arn:aws:s3:::mybucket/*"
	            ]
	        }
	    ]
	}
Replacing ‘mybucket’ (twice) with your bucket name.

4. Point the DNS on your domain to s3.

Create a CNAME to mybucket.s3-website-us-east-1.amazonaws.com [replace ‘us-east-1 with the region of the bucket].
5. Setup the build on Codeship

Sign up to Codeship with your Bitbucket account.
Create a new project connected to the Bitbucket ‘myblog’ repository.
Choose “I want to create my own custom commands”
In Setup Commands enter: scripts/install-hugo.sh
In Configure Test Pipelines enter: ./hugo -v --theme=<your choice of theme>
Save, go to dashboard - you could test run it at this point, though it won’t upload to anywhere (yet!).
Add a Deployment pipeline for the ‘master’ branch, select ‘Amazon S3’.
Enter the credentials from (3), set Local Path to public, fill in S3 bucket, and set Acl as public-read. Set region if you created the bucket
Save this, and kick off a build.
Hopefully the build will run through to success, and your site will go live.

And whenever you make another commit, Codeship will be triggered, the site rebuilt and uploaded to S3 - all in all the process is very quick - 20-30s for me! You can even create posts from the browser based Bitbucket editor if you’re out and about, and it’ll be published automatically.
