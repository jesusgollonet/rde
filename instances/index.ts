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

// Create the EC2 instance
const rdeInstance = new aws.ec2.Instance("rde", {
    ami: ami,
    instanceType: "t3.micro",
}, { provider });

// Export the instance ID and public IP
export const instanceId = rdeInstance.id;
export const publicIp = rdeInstance.publicIp;
