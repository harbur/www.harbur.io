+++
date = "2016-04-05T08:48:07+02:00"
title = "Case Study - Onebox"
+++

[![Onebox](/images/icons/clients/onebox.jpg)](http://oneboxtm.com)

# About the Client

Set up in Barcelona in 2010, the result of the need of a sector to improve its management model, change the established order and prepare for a future market through innovation and better relationships with people and the environment.
This premise drove them to research and develop tools providing added value to the different agents involved in the industry, with the final aim of offering the best service to leisure and showbusiness consumers.

They have a wide-ranging catalogue of solutions providing service to show organisers, venues, sales channels and organisations interested in selling tickets.

[Onebox](http://www.oneboxtm.com) makes available to its clients the technology they need to take control of ticketing for their shows, make it easier to open up and distribute tickets on new sales channels and manage to sell all the tickets for their shows.


# Objectives

They are handling big amount of traffic and have some specific patterns such as big peeks during high-profile events. Their objective is to migrate to a microservice oriented development process, leveraging containers as their
deployment units.

* Continuous Integration with Docker, Jenkins, AWS

# Design

![Onebox-badges](/images/icons/clients/onebox-badges.png)

The first stage was to introduce the tools needed in order to be able to create a cluster of containers. The applications are deployed as units of [Docker](https://www.docker.com/) containers. For host Operating System we used [CoreOS](https://coreos.com/) namely because of their atomic update process and minimalistic concept of container-host environment. On top of the host OS we chose [Kubernetes](http://kubernetes.io) as the Control Plane of the containers. For networking fabric we used [Flannel](https://github.com/coreos/flannel) on the on-premises environments.

The second stage was to design the development-to-production workflow using containers as the deployment unit. Since the microservices are mostly Java Web applications, a base image was introduced with two-folded purpose; Firstly, it abstracts away from each microservice the installation process of the dependencies, following the [DRY](http://programmer.97things.oreilly.com/wiki/index.php/Don't_Repeat_Yourself) (Don't Repeat Yourself) principle. Secondly, the base image is part of the Operations assets, which makes it possible to audit, and secure the images from security vulnerabilities.

The microservices now inherit the base image and have their own image namespace and are versioned following the git workflow and tags by using [Captain](https://github.com/harbur/captain) and [Jenkins](https://jenkins.io/).

The Service Discovery is done using Netflix [Eureka](https://github.com/Netflix/eureka). Eureka is a REST (Representational State Transfer) based service that is primarily used in the AWS cloud for locating services for the purpose of load balancing and failover of middle-tier servers.

Separate clusters were created for different environments, development cluster is segmented for each team using separate kubernetes namespaces. A high-level abstraction diagram of each environment can be seen on the following diagram:

![Onebox Cluster](/images/icons/clients/onebox-cluster.png)
