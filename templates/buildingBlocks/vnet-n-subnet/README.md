# vnet-n-subnet

You can use the vnet-n-subnet building block to deploy an [Azure virtual network (VNet)](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-overview/). This building block deploys a virtual network with no additional resources. Use this building block to deploy a VNet with no Network Security Groups (NSGs) or User Defined Routes (UDRs). If you want to deploy a VNet with that includes NSGs or UDRs, use the following buildling blocks: 

- [Network Security Groups](https://github.com/mspnp/template-building-blocks/tree/master/templates/buildingBlocks/networkSecurityGroups)
- [User Defined Routes](https://github.com/mspnp/template-building-blocks/tree/master/templates/buildingBlocks/userDefinedRoutes)

**Note** We chose to have separate building block for NSGs and UDRs so that these can be applied individually, without redefining the entire virtual network. Most deployments use extensions that require access to the Internet during deployment. By separating these blocks, you can deploy the VNet and your VMs, and then tighten security with NSGs and UDRs.

## Parameters

You only need to specify one parameter in this building block, named **virtualNetworkSettings**. This parameter is an object that contains the following properties:

- **name**  
  _Value_. _Required_.
  Name of the VNet. Example:  
  ```json
  "name": "bb-dev-vnet"
  ```
- **addressPrefixes**  
  _Array of values_. _Requires at least one value._ Defines the CIDR address blocks for the entire VNet. Supports multiple CIDR prefixes. Example:
  ```json
  "addressPrefixes": [ "10.0.0.0/16" ]
  ```

- **subnets**  
_Array of objects_. _Requires at least one object_. Defines the subnets within the VNet. Subnets are defined by the following object:
  - **name** - _Value_. _Required._ Name of the subnet.
  - **addressPrefix** - _Value_. _Required_. CIDR address block for the subnet (must be valid within the VNet address space definition).
  Example:
  ```json
  "subnets": [
    {
      "name": "privateSub", 
      "addressPrefix": "10.0.0.0/24"
    }, 
    {
      "name": "publicSub", 
      "addressPrefix": "10.0.1.0/24"
    }
  ]
  ```
- **dnsServers**  
  _Array of values_. _Requires at least one object_. Defines one or more custom DNS Server address for the VNet. Example:
  ```json
  "dnsServers": ["10.0.0.220","10.0.1.233"]
  ```
  **Note** Leave the array empty to use Azure internal name resolution. Example:
  ```json 
  "dnsServers": [ ] 
  ```

## Sample parameter file

The following parameter file will create a VNet with subnets suitable for a three-tiered architecture, a management subnet, and a gateway subnet:

```json
{
  "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "virtualNetworkSettings": {
      "value": {
        "name": "bb-dev-vnet",
        "addressPrefixes": [ "10.0.0.0/16" ],
        "subnets": [
          {
            "name": "web",
            "addressPrefix": "10.0.1.0/24"
          },
          {
            "name": "biz",
            "addressPrefix": "10.0.2.0/24"
          },
          {
            "name": "data",
            "addressPrefix": "10.0.3.0/24"
          },
          {
            "name": "management",
            "addressPrefix": "10.0.0.128/25"
          },
          {
            "name": "GatewaySubnet",
            "addressPrefix": "10.0.255.224/27"
          }
        ],
        "dnsServers": [ ]
      }
    }
  }
}
```
## Deployment

### Azure portal

Note that the building block deployment process will require you store your parameters file in a location with a publicly available URI, which you provide during deployment.

1. Right click the button below and select the option to open the link in a new tab or a new window:<br><a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmspnp%2Ftemplate-building-blocks%2Fv1.0.0%2Fscenarios%2Fvnet-n-subnet%2Fazuredeploy.json" target="_blank"><img src = "http://azuredeploy.net/deploybutton.png"/></a>
2. Wait for the Azure Portal to open.
3. In the `Basics` section:
  - Select your `Subscription` from the drop-down list.
  - For the `Resource group`, you can either create a new resource group or use an existing resource group.
  - Select the region where you'd like to deploy the VNet in the `Location` drop-down list.
4. In the `Settings` section, enter a URI to a valid parameter file. ee/v1.0.0/scenarios/vnet-n-subnet/parameters) in Github. Note that if you want to use one of these parameter files the URI must be the path to the `raw` file in Github. 
5. Review the terms and conditions, then click the **I agree to the terms and conditions stated above** checkbox.
6. Click the **Purchase** button.
7. Wait for the deployment to complete.
