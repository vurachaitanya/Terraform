#### Meta Parameters
- count(int)
- dependes_on (list of strings)
- provider (string)
- lifecycle (configuration block)

#### Count:
- Assign ips with seq and name in required seq format.

```
 variable "instance_ips" {
   default = {
     "0" = "10.1.1.10"
	 "1" = "10.1.1.11"
	 "2" = "10.1.1.12"
	 }
	}
	
resource "aws_instance" "webserver" {
  count = "3"
  private_ip = "${lookup(var.instance_ips,count.index)}"
  tags {
    Name = "${format{"web-%03d",countindex + 1)}"
   }
```
- AWS instance with 1st host ip 10.1.1.10 and host name as web-001 is created and 10.1.1.11 with host name web-002, etc
- [Looping function](https://www.terraform.io/docs/language/functions/lookup.html)

#### lifecycle :
- Instances will created first and then destroy old resources to prevent the loss of service. 
```
lifecycle {
  create_before_destroy = true
}
```

#### Time outs
- timeout give for any activity to wait for that long to complete or terminate post that time is end.

```
timeout {
  create = "2s"
  update = "20m"
  delete = "1h"
}
```

#### Data sources configurations
- Fetch the avilability zones mapped to the aws provider
- list of zones from aws which we will use later
- data source is of the form data TYPE Name where
- TYPE = aws_availability_zones
- Name = "avilable"

- Define data block 
`data "availability_zones` "avilable" {}`
- used in resurces
```
resource "aws_subnet" "subnet1" {
  cidr_block = "${var.subnet1_address_space}"
  vpc_id = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "true"
  availablity_zone = "${data.aws_availability_zones.available.names[0]}"
}
  
```
- **Data sources**
- Data sources support some meta-parameters
- Data sources present read-only views
- All data sources are mapped to a provider

- **Override**
- Override files are merged with loaded configuration files
- Override files are loaded in alphabetical order
- Override files are loaded after non-override files
