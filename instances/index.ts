import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Get configuration values
const config = new pulumi.Config();
const region = config.require("region");

// Create the AWS provider with the specified region
const provider = new aws.Provider("aws-provider", {
    region: region as aws.Region,
});

// Automatically find the latest rde-ami
const latestRdeAmi = aws.ec2.getAmi({
    filters: [
        {
            name: "name",
            values: ["rde-ami"],
        },
        {
            name: "state",
            values: ["available"],
        },
    ],
    mostRecent: true,
    owners: ["self"], // Only our own AMIs
}, { provider });

// Create a security group that allows SSH and Mosh access
const sshSecurityGroup = new aws.ec2.SecurityGroup("rde-ssh", {
    description: "Allow SSH and Mosh access",
    ingress: [
        {
            protocol: "tcp",
            fromPort: 22,
            toPort: 22,
            cidrBlocks: ["0.0.0.0/0"],
        },
        {
            protocol: "udp",
            fromPort: 60000,
            toPort: 61000,
            cidrBlocks: ["0.0.0.0/0"],
        },
    ],
    egress: [
        {
            protocol: "-1",
            fromPort: 0,
            toPort: 0,
            cidrBlocks: ["0.0.0.0/0"],
        },
    ],
    tags: {
        Name: "rde-ssh-mosh-sg",
        Project: "rde",
    },
}, { provider });

// Create the EC2 instance
const rdeInstance = new aws.ec2.Instance("rde", {
    ami: latestRdeAmi.then(ami => ami.id),
    instanceType: "t3.micro",
    securityGroups: [sshSecurityGroup.name],
    tags: {
        Name: "rde-instance",
        Project: "rde",
    },
}, { provider });

// Export the instance ID, public IP, and AMI ID used
export const instanceId = rdeInstance.id;
export const publicIp = rdeInstance.publicIp;
export const amiId = latestRdeAmi.then(ami => ami.id);
