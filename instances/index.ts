import * as pulumi from "@pulumi/pulumi";
import * as aws from "@pulumi/aws";

// Get configuration values
const config = new pulumi.Config();
const region = config.require("region");
const ami = config.require("ami");

// Create the AWS provider with the specified region
const provider = new aws.Provider("aws-provider", {
    region: region as aws.Region,
});

// Create a security group that allows SSH access
const sshSecurityGroup = new aws.ec2.SecurityGroup("rde-ssh", {
    description: "Allow SSH access",
    ingress: [
        {
            protocol: "tcp",
            fromPort: 22,
            toPort: 22,
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
        Name: "rde-ssh-sg",
        Project: "rde",
    },
}, { provider });

// Create the EC2 instance
const rdeInstance = new aws.ec2.Instance("rde", {
    ami: ami,
    instanceType: "t3.micro",
    securityGroups: [sshSecurityGroup.name],
    tags: {
        Name: "rde-instance",
        Project: "rde",
    },
}, { provider });

// Export the instance ID and public IP
export const instanceId = rdeInstance.id;
export const publicIp = rdeInstance.publicIp;
