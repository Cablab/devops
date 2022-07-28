# CloudFormation

[CloudFormation Docs](https://docs.aws.amazon.com/cloudformation/index.html)

CloudFormation is an IaaC tool, like Terraform, but specifically for AWS

- **Template** - a YAML or JSON file that CloudFormation will read to make changes
- **Stack** - a single unit of resources that defines the state of infrastructure
- **Change Set** - Before applying changes to a Stack, you can generate a Change Set to see what changes will be made

## Template Structure

General Fields:

- **AWSTemplateFormatVersion**: version date of Template
- **Description** - describes template
- **Metadata** - describes template
- **Parameters** - input into the template
- **Mappings** - key-value pair store
- **Conditions** - conditional definitions
- **Transform** - useful for serverless application 
- **Resources** - define AWS resources to create
- **Outputs** - output after template is created

## Intrinsic Functions

[Intrinsic Function Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/intrinsic-function-reference.html)

- Intrinsic Functions are built-in functions that CloudFormation can do
- For an example, see [exercises/functions.yaml](exercises/functions.yaml)
- A really common use is `!Ref`, which lets you reference other Resources you have already defined in the Template by calling `!Ref <resource-Logical-ID>`
  - You can also call built-in [psuedo parameters](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/pseudo-parameter-reference.html)

## Mappings

[Mappings Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/mappings-section-structure.html)

- Mappings create a map of key-value pairs that you can reference in other places in the Template
- See [exercises/mappings-example.yaml](exercises/mappings-example.yaml) for an example

## Parameters

[Parameters Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html)

- Parameters allow users to specify input from users
- Users will input the parameters on CloudFormation when creating the Stack
- See [exercises/input-parameters.yaml](exercises/input-parameters.yaml) for an example

## Outputs

[Outputs Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html)

- Outputs allow you print information after the Stack has been created
- You can use these to either return a `Value` for visibility for `Export` a value that subsequent Templates could use in a multi-template nested setup
- When the Stack finishes execution, the check the `Output` tab to see the output
- Use `!GetAtt <Logical-ID>.<AttributeName>` intrinsic function to get the value of an attribute inside of block you declared in the Template
- See [exercises/output-example.yaml](exercises/output-example.yaml) for an example

## Metadata Init

[AWS::CloudFormation::Init Docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-init.html)

- When defining a resource, you can use the `Metadata.AWS::CloudFormation::Init` object to define provisioning steps that the resource should take once it's up
- See [exercises/init.yaml](exercises/init.yaml) for an example

## Web UI Interactions

- Go to `CloudFormation` in AWS and `Create Stack`
- Use `Template is ready` and `Upload a template file` to create a template from a file you've already written locally
  - You can use `Amazon S3 URL` if you wrote a template file and put it in an S3 bucket
- Once uploaded, you can `View in Designer` to see a graphical layout of the Stack that will be created
  - In this screen, there's a little check mark in the top left you can click to validate the file you've uploaded
  - To go back to the Stack creation screen, hit the cloud with an arrow symbol
- Once a Stack is created, watch  the `Events` tab to see it running
- You can update a Stack by clicking the `Update` button and uploading a new/updated Template file
- You can delete a Stack by clicking the `Delete` button. This will delete all resources in the stack that were defined by the template

## Examples

- [exercises/first-example.yaml](exercises/first-example.yaml) - create an EC2 instance
- [exercises/functions.yaml](exercises/functions.yaml) - showing `!Join` function
- [exercises/ref-function.yaml](exercises/ref-function.yaml) - showing `!Ref` with pseudo parameter
- [exercises/multi-resource.yaml](exercises/multi-resource.yaml) - showing `!Ref` targeting a separate resource defined in the same file
- [exercises/mappings-example](exercises/mappings-example.yaml) - showing Mappings and `!FindInMap`
- [exercises/input-parameters.yaml](exercises/input-parameters.yaml) - showing input parameters that users can choose at Stack creation time
- [exercises/output-example.yaml](exercises/output-example.yaml) - showing value output
- [exercises/init.yaml](exercises/init.yaml) - showing example of init metadata

## VSCode Syntax for YAML + CloudFormation

To fix YAML showing syntax errors on CloudFormation intrinsic functions, see the fix [at this link](https://github.com/redhat-developer/yaml-language-server/issues/77#issuecomment-511768680). You have to add the intrinsic functions to the YAML extensions custom tags
